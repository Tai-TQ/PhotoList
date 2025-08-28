//
//  ImageCache.swift
//  Data
//
//  Created by TaiTruong on 26/8/25.
//

import UIKit

/// A lightweight disk-based image cache.
///
/// How it works:
/// - Generates a cache key from the image URL and target size (width x height).
/// - When saving, it JPEG-encodes the input image, writes a temporary file,
///   then downsamples that file to the requested size using CGImageSource
///   for memory-efficient processing, re-encodes to JPEG, writes to disk,
///   and finally enforces a disk size limit with LRU-like eviction.
/// - When reading, it looks up the file by key and returns a UIImage if found.
///
/// Threading:
/// - All disk I/O and image downsampling are performed on a serial utility queue.
/// - Callbacks from `getCachedImage` are invoked on that background queue
///   (dispatch back to the main queue before touching UI).
///
/// Notes:
/// - Disk limit defaults to 5 GB; eviction removes oldest files until ~80% of limit.
/// - Keys are URL + size; scale only affects downsampling quality, not the key itself.
/// - No in-memory cache or TTL is provided.
///
/// Rationale:
/// - This app currently displays these images on a single screen at a fixed target size,
///   so caching full-resolution originals adds cost without user-visible benefit.
/// - Downsampling before saving shrinks file size and decode work, which makes disk I/O
///   and image decoding faster, improving time-to-first-pixel and scroll smoothness.

final class ImageCache {
    nonisolated(unsafe) static let shared = ImageCache()

    private let fileManager = FileManager.default
    private let diskCacheURL: URL

    private let diskQueue = DispatchQueue(label: "ImageCache.disk", qos: .utility)

    private let maxDiskSize: Int = 5 * 1024 * 1024 * 1024 // 5GB

    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = caches.appendingPathComponent("ImageCache")

        diskQueue.sync {
            if !fileManager.fileExists(atPath: diskCacheURL.path) {
                try? fileManager.createDirectory(at: diskCacheURL,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
            }
        }
    }

    // MARK: - Public API

    /// Saves an image to disk in a downsampled form for the given URL and size.
    /// - Parameters:
    ///   - image: Source image to store.
    ///   - url: Original remote or local URL used as part of the cache key.
    ///   - targetSize: Size in points to downsample to (used in the key as WxH).
    ///   - scale: Display scale used to compute pixel size for downsampling.
    ///
    /// Processing pipeline:
    /// 1) JPEG-encode `image` -> write to a temp file
    /// 2) Downsample the temp file to `targetSize * scale` via CGImageSource
    /// 3) JPEG-encode the thumbnail -> write under the derived cache key
    /// 4) Remove temp file and enforce disk usage limits
    public func saveImage(_ image: UIImage, for url: URL, targetSize: CGSize, scale: CGFloat) {
        let key = cacheKey(for: url, targetSize: targetSize)

        diskQueue.async { [weak self] in
            guard let self = self else { return }

            guard let data = image.jpegData(compressionQuality: 0.8),
                  let tmpURL = try? self.writeTempFile(data: data),
                  let downsampled = self.downsampleImage(at: tmpURL, to: targetSize, scale: scale),
                  let downsampledData = downsampled.jpegData(compressionQuality: 0.8)
            else {
                return
            }

            let fileURL = self.diskCacheURL.appendingPathComponent(key)
            try? downsampledData.write(to: fileURL)

            try? FileManager.default.removeItem(at: tmpURL)

            self.enforceLimits()
        }
    }

    /// Loads a cached image from disk for the given URL and size, if available.
    /// - Parameters:
    ///   - url: Original image URL used to build the cache key.
    ///   - targetSize: Size in points that was used when saving.
    ///   - completion: Called with the decoded `UIImage` or `nil` if not found.
    ///
    /// Note: `completion` is invoked on the cache's background queue.
    public func getCachedImage(for url: URL, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let key = cacheKey(for: url, targetSize: targetSize)
        diskQueue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }

            let fileURL = self.diskCacheURL.appendingPathComponent(key)
            if let data = try? Data(contentsOf: fileURL),
               let img = UIImage(data: data)
            {
                completion(img)
            } else {
                completion(nil)
            }
        }
    }

    // MARK: - Private func

    private func cacheKey(for url: URL, targetSize: CGSize) -> String {
        "\(url.absoluteString)_\(Int(targetSize.width))x\(Int(targetSize.height))"
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
    }

    private func writeTempFile(data: Data) throws -> URL {
        let tmpURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try data.write(to: tmpURL)
        return tmpURL
    }

    private func downsampleImage(at url: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOptions) else {
            return nil
        }

        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(maxDimensionInPixels),
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    private func enforceLimits() {
        guard let files = try? fileManager.contentsOfDirectory(
            at: diskCacheURL,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
            options: []
        ) else { return }

        let totalSize = files.compactMap { url -> Int? in
            (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize
        }.reduce(0, +)

        if totalSize > maxDiskSize {
            let sortedFiles = files.compactMap { url -> (URL, Date, Int)? in
                let values = try? url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
                guard let date = values?.contentModificationDate,
                      let size = values?.fileSize else { return nil }
                return (url, date, size)
            }.sorted { $0.1 < $1.1 }

            // Delete oldest files until under limit
            var currentSize = totalSize
            let targetSize = Int(Double(maxDiskSize) * 0.8) // Leave 20% buffer

            for (url, _, size) in sortedFiles {
                if currentSize <= targetSize { break }

                try? fileManager.removeItem(at: url)
                currentSize -= size
            }
        }
    }
}

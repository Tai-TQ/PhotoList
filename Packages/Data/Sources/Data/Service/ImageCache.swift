//
//  ImageCache.swift
//  Data
//
//  Created by TaiTruong on 26/8/25.
//

import UIKit

class ImageCache {
    nonisolated(unsafe) static let shared = ImageCache()

    private let fileManager = FileManager.default
    private let diskCacheURL: URL
    
    // Serial queue để synchronize disk operations
    private let diskQueue = DispatchQueue(label: "ImageCache.disk", qos: .utility)

    private let maxDiskSize: Int = 5 * 1024 * 1024 * 1024   // 5GB

    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = caches.appendingPathComponent("ImageCache")

        // Disk operations cũng cần serialize
        diskQueue.sync {
            if !fileManager.fileExists(atPath: diskCacheURL.path) {
                try? fileManager.createDirectory(at: diskCacheURL,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
            }
        }
    }

    // MARK: - Public API

    public func saveImage(_ image: UIImage, for url: URL, targetSize: CGSize, scale: CGFloat) {
        let key = cacheKey(for: url, targetSize: targetSize)

        // Disk operations - serialized
        diskQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard let data = image.jpegData(compressionQuality: 0.8),
                  let tmpURL = try? self.writeTempFile(data: data),
                  let downsampled = self.downsampleImage(at: tmpURL, to: targetSize, scale: scale),
                  let downsampledData = downsampled.jpegData(compressionQuality: 0.8) else {
                return
            }

            // Save to disk (serialized)
            let fileURL = self.diskCacheURL.appendingPathComponent(key)
            try? downsampledData.write(to: fileURL)

            // Clean up temp file
            try? FileManager.default.removeItem(at: tmpURL)

            // Enforce limits (serialized)
            self.enforceLimits()
        }
    }

    public func getCachedImage(for url: URL, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let key = cacheKey(for: url, targetSize: targetSize)
        // Disk read - serialized
        diskQueue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            let fileURL = self.diskCacheURL.appendingPathComponent(key)
            if let data = try? Data(contentsOf: fileURL),
               let img = UIImage(data: data) {
                completion(img)
            } else {
                completion(nil)
            }
        }
    }

    // MARK: - Synchronous version for backwards compatibility
    public func getCachedImageSync(for url: URL, targetSize: CGSize) -> UIImage? {
        let key = cacheKey(for: url, targetSize: targetSize)
        
        // Disk read - synchronous but thread-safe
        return diskQueue.sync { [weak self] in
            guard let self = self else { return nil }
            
            let fileURL = self.diskCacheURL.appendingPathComponent(key)
            if let data = try? Data(contentsOf: fileURL),
               let img = UIImage(data: data) {
                return img
            }
            return nil
        }
    }

    // MARK: - Admin functions (all serialized)
    
    func clearDisk() {
        diskQueue.async { [weak self] in
            guard let self = self else { return }
            try? self.fileManager.removeItem(at: self.diskCacheURL)
            try? self.fileManager.createDirectory(at: self.diskCacheURL,
                                                  withIntermediateDirectories: true,
                                                  attributes: nil)
        }
    }

    func currentDiskUsage() -> Int {
        return diskQueue.sync { [weak self] in
            guard let self = self else { return 0 }
            
            guard let files = try? self.fileManager.contentsOfDirectory(
                at: self.diskCacheURL,
                includingPropertiesForKeys: [.fileSizeKey],
                options: []
            ) else { return 0 }
            
            return files.compactMap {
                (try? $0.resourceValues(forKeys: [.fileSizeKey]))?.fileSize
            }.reduce(0, +)
        }
    }

    // MARK: - Private Helpers

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
            kCGImageSourceThumbnailMaxPixelSize: Int(maxDimensionInPixels)
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    // Chạy trong diskQueue để thread-safe
    private func enforceLimits() {
        // Tất cả operations phải trong cùng diskQueue
        guard let files = try? fileManager.contentsOfDirectory(
            at: diskCacheURL,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
            options: []
        ) else { return }
        
        // Tính usage trong cùng queue
        let totalSize = files.compactMap { url -> Int? in
            (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize
        }.reduce(0, +)
        
        // Check if cleanup needed
        if totalSize > maxDiskSize {
            // Sort by modification date (LRU)
            let sortedFiles = files.compactMap { url -> (URL, Date, Int)? in
                let values = try? url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
                guard let date = values?.contentModificationDate,
                      let size = values?.fileSize else { return nil }
                return (url, date, size)
            }.sorted { $0.1 < $1.1 } // Oldest first
            
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

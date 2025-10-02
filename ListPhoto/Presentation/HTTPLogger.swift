import Foundation
import CocoaLumberjackSwift
import UIKit

/// HTTPLogger: custom CocoaLumberjack logger that batches logs and POSTs them to an endpoint.
/// - Note: use `HTTPLogger.shared.configure(...)` then `DDLog.add(HTTPLogger.shared, with: .all)`
public final class HTTPLogger: DDAbstractLogger {

    public static let shared = HTTPLogger()

    // MARK: config
    public var endpointURL: URL?
    public var batchSize: Int = 25
    public var flushInterval: TimeInterval = 2.0
    public var maxBufferSize: Int = 2000
    public var maxRetries: Int = 3

    // MARK: internals
    private let queue = DispatchQueue(label: "com.yourapp.HTTPLogger", qos: .utility)
    private var buffer: [[String: Any]] = []
    private var timer: DispatchSourceTimer?
    private var isSending = false
    private lazy var session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.httpMaximumConnectionsPerHost = 4
        cfg.timeoutIntervalForRequest = 10
        return URLSession(configuration: cfg)
    }()
    private lazy var iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    // prevent external init
    private override init() {
        super.init()
        startTimer()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillTerminate),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }

    deinit {
        stopTimer()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public configure
    public func configure(endpoint: URL,
                          batchSize: Int = 25,
                          flushInterval: TimeInterval = 2.0,
                          maxBufferSize: Int = 2000) {
        queue.sync {
            self.endpointURL = endpoint
            self.batchSize = batchSize
            self.flushInterval = flushInterval
            self.maxBufferSize = maxBufferSize
            self.stopTimer()
            self.startTimer()
        }
    }

    // MARK: - DDAbstractLogger entry
    public override func log(message logMessage: DDLogMessage) {
        // Build level
        let levelString: String = {
            if logMessage.flag.contains(.error) { return "error" }
            if logMessage.flag.contains(.warning) { return "warn" }
            if logMessage.flag.contains(.info) { return "info" }
            if logMessage.flag.contains(.debug) { return "debug" }
            return "verbose"
        }()

        // Build JSON entry
        let fileName = (logMessage.file as NSString).lastPathComponent
        let entry: [String: Any] = [
            "timestamp": iso8601.string(from: logMessage.timestamp),
            "level": levelString,
            "message": logMessage.message,
            "file": fileName,
            "function": logMessage.function ?? "",
            "line": Int(logMessage.line),
            "thread": logMessage.threadID
        ]
        print("👉 [HTTPLogger] prepared entry:", entry)
        // enqueue
        queue.async {
            self.buffer.append(entry)
            print("👉 [HTTPLogger] buffer count = \(self.buffer.count)")
            // cap buffer
            if self.buffer.count > self.maxBufferSize {
                let removeCount = self.buffer.count - self.maxBufferSize
                self.buffer.removeFirst(removeCount)
                print("⚠️ [HTTPLogger] buffer overflow, dropped \(removeCount) oldest entries")

            }
            if self.buffer.count >= self.batchSize {
                print("🚀 [HTTPLogger] batchSize reached, flushing now")
                self.flushBuffer()
            }
        }
    }

    // MARK: - Buffer flush (non-conflicting name)
    private func flushBuffer() {
        guard !isSending, !buffer.isEmpty, let endpoint = endpointURL else {
            if buffer.isEmpty {
                print("👉 [HTTPLogger] flushBuffer called, but buffer empty")
            }
            return
        }
        isSending = true

        // snapshot
        let toSend = buffer
        buffer.removeAll()
        print("🚀 [HTTPLogger] flushing \(toSend.count) logs to \(endpoint)")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Wrap payload (server in guide expected array or object - adjust as your server needs)
        let payload: Any = ["logs": toSend]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("❌ [HTTPLogger] JSON serialization failed:", error)

            // requeue on serialization failure
            queue.async {
                self.buffer.insert(contentsOf: toSend, at: 0)
                self.isSending = false
            }
            return
        }

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            self.queue.async {
                defer { self.isSending = false }
                if let err = error {
                    print("❌ [HTTPLogger] network error:", err)

                    self.handleSendFailure(batch: toSend, attempt: 1, error: err)
                    return
                }
                if let http = response as? HTTPURLResponse {
                    print("✅ [HTTPLogger] server responded:", http.statusCode)
                    if let data = data, let body = String(data: data, encoding: .utf8) {
                        print("📦 [HTTPLogger] response body:", body)
                    }
                    if !(200...299).contains(http.statusCode) {
                        let err = NSError(domain: "HTTPLogger", code: http.statusCode, userInfo: nil)
                        self.handleSendFailure(batch: toSend, attempt: 1, error: err)
                        return
                    }
                }
                // success: nothing to do
            }
        }
        task.resume()
    }

    private func handleSendFailure(batch: [[String: Any]], attempt: Int, error: Error) {
        if attempt < maxRetries {
            let delay = pow(2.0, Double(attempt))
            queue.asyncAfter(deadline: .now() + delay) {
                // retry by placing back to buffer front and calling flush again
                self.buffer.insert(contentsOf: batch, at: 0)
                self.flushBuffer()
            }
        } else {
            // give up temporarily: requeue at front (but drop oldest if too large)
            buffer.insert(contentsOf: batch, at: 0)
            if buffer.count > maxBufferSize {
                buffer.removeFirst(buffer.count - maxBufferSize)
            }
        }
    }

    // MARK: - Timer
    private func startTimer() {
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + flushInterval, repeating: flushInterval)
        t.setEventHandler { [weak self] in
            self?.flushBuffer()
        }
        t.resume()
        timer = t
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    // MARK: - App lifecycle
    @objc private func appDidEnterBackground() {
        queue.async {
            var bgTask: UIBackgroundTaskIdentifier = .invalid
            bgTask = UIApplication.shared.beginBackgroundTask(withName: "HTTPLoggerFlush") {
                UIApplication.shared.endBackgroundTask(bgTask)
            }
            self.flushBuffer()
            // give a short grace period
            self.queue.asyncAfter(deadline: .now() + 1.0) {
                UIApplication.shared.endBackgroundTask(bgTask)
            }
        }
    }

    @objc private func appWillTerminate() {
        queue.sync {
            self.flushBuffer()
        }
    }
}


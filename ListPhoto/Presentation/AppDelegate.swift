//
//  AppDelegate.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit
import CocoaLumberjackSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let formatter = MyLogFormatter()

//        // DDOSLogger (os_log)
//        DDOSLogger.sharedInstance.logFormatter = formatter
//        DDLog.add(DDOSLogger.sharedInstance, with: .all)

        // File logger
//        let fileLogger = DDFileLogger()
//        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
//        fileLogger.rollingFrequency = 60*60*24
//        fileLogger.logFormatter = formatter
//        DDLog.add(fileLogger, with: .all)

        // HTTP logger
        HTTPLogger.shared.configure(endpoint: URL(string: "http://localhost:3000/logs")!,
                                    batchSize: 20,
                                    flushInterval: 2.0)
        DDLog.add(HTTPLogger.shared, with: .all)


        DDLogDebug("This is a debug message")
        DDLogInfo("This is an info message")
        DDLogWarn("This is a warning")
        DDLogError("This is an error")
        return true
    }
}

class MyLogFormatter: NSObject, DDLogFormatter {
    func format(message logMessage: DDLogMessage) -> String? {
        let date = DateFormatter.localizedString(from: logMessage.timestamp, dateStyle: .short, timeStyle: .medium)
        return "[\(date)] [\(logMessage.flag)] [\(logMessage.fileName):\(logMessage.line)] \(logMessage.message)"
    }
}

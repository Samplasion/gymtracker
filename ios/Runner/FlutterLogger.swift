//
//  FlutterLogger.swift
//  Runner
//
//  Created by Francesco Arieti on 01/08/25.
//

import Foundation
import Flutter

class FlutterLogger {
    private let channel: GymBroNativeLoggerChannelProtocol
    
    init(binaryMessenger: FlutterBinaryMessenger) {
        channel = GymBroNativeLoggerChannel(binaryMessenger: binaryMessenger)
    }
    
    func log(_ message: String) {
        channel.logMessage(message: message, completion: {_ in})
    }
    
    func error(_ message: String) {
        channel.logError(error: message, completion: {_ in})
    }

    func error(_ error: Error, context: String) {
        let nsError = error as NSError
        // An unreachable paired device is expected when the Watch is offline.
        guard nsError.domain != "WCErrorDomain" || nsError.code != 7007 else { return }
        self.error("\(context): \(error)")
    }
}

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
}

//
//  File.swift
//  GymBroWatch Watch App
//
//  Created by Francesco Arieti on 26/12/25.
//

import Foundation

import Foundation
import os

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    #if os(watchOS)
    static let shared = Logger(subsystem: subsystem, category: "GymBroWatch")
    #else
    static let shared = Logger(subsystem: subsystem, category: "GymBro")
    #endif
}

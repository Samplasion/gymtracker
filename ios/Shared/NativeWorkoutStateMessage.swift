//
//  NativeWorkoutStateMessage.swift
//  Runner
//
//  Created by Francesco Arieti on 31/07/25.
//

import Foundation
import SwiftUI

struct NativeWorkoutStateMessage: Codable {
    let hasExercise: Bool
    let exerciseName: String
    let exerciseColor: Int64
    let exerciseParameters: String
    let startingTime: Date
    let restTimeStart: Date?
    let restTimeEnd: Date?
    let percentageDone: Double

    enum CodingKeys: String, CodingKey {
        case hasExercise
        case exerciseName
        case exerciseColor
        case exerciseParameters
        case startingTime
        case restTimeStart
        case restTimeEnd
        case percentageDone
    }

    // Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hasExercise, forKey: .hasExercise)
        try container.encode(exerciseName, forKey: .exerciseName)
        try container.encode(exerciseColor, forKey: .exerciseColor)
        try container.encode(exerciseParameters, forKey: .exerciseParameters)
        try container.encode(startingTime.millisecondsSinceEpoch, forKey: .startingTime)
        try container.encodeIfPresent(restTimeStart?.millisecondsSinceEpoch, forKey: .restTimeStart)
        try container.encodeIfPresent(restTimeEnd?.millisecondsSinceEpoch, forKey: .restTimeEnd)
        try container.encode(percentageDone, forKey: .percentageDone)
    }
    
    func toJSON() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
    
    func toJSONString() throws -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: toJSON() as Any),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return nil
    }

    // Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasExercise = try container.decode(Bool.self, forKey: .hasExercise)
        exerciseName = try container.decode(String.self, forKey: .exerciseName)
        exerciseColor = try container.decode(Int64.self, forKey: .exerciseColor)
        exerciseParameters = try container.decode(String.self, forKey: .exerciseParameters)
        let startMillis = try container.decode(Int.self, forKey: .startingTime)
        startingTime = Date(milliseconds: startMillis)
        if let restStartMillis = try container.decodeIfPresent(Int.self, forKey: .restTimeStart) {
            restTimeStart = Date(milliseconds: restStartMillis)
        } else {
            restTimeStart = nil
        }
        if let restEndMillis = try container.decodeIfPresent(Int.self, forKey: .restTimeEnd) {
            restTimeEnd = Date(milliseconds: restEndMillis)
        } else {
            restTimeEnd = nil
        }
        percentageDone = try container.decode(Double.self, forKey: .percentageDone)
    }
    
    static func decodeWorkoutState(fromString string: String) -> NativeWorkoutStateMessage? {
        if let data = string.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return decodeWorkoutState(from: dict)
        }
        
        return nil
    }
    
    static func decodeWorkoutState(from dictionary: [String?: Any?]) -> NativeWorkoutStateMessage? {
        // Step 1: Filter out nil keys or nil values
        var sanitized: [String: Any] = [:]
        for (keyOpt, valueOpt) in dictionary {
            if let key = keyOpt, let value = valueOpt {
                sanitized[key] = value
            }
        }

        // Step 2: Convert to JSON Data
        guard JSONSerialization.isValidJSONObject(sanitized),
              let jsonData = try? JSONSerialization.data(withJSONObject: sanitized) else {
            print("Invalid JSON object")
            return nil
        }

        // Step 3: Decode using JSONDecoder
        let decoder = JSONDecoder()
        do {
            let message = try decoder.decode(NativeWorkoutStateMessage.self, from: jsonData)
            return message
        } catch {
            print("Decoding failed:", error)
            return nil
        }
    }
}

// MARK: - Extensions

extension Color {
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)

        let r, g, b: Double
        if hexString.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        } else {
            r = 0; g = 0; b = 0
        }

        self.init(red: r, green: g, blue: b)
    }

    var hexString: String {
        guard let cgColor = UIColor(self).cgColor.components, cgColor.count >= 3 else {
            return "#000000"
        }
        let r = Int(cgColor[0] * 255)
        let g = Int(cgColor[1] * 255)
        let b = Int(cgColor[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

extension Date {
    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }

    var millisecondsSinceEpoch: Int {
        Int(self.timeIntervalSince1970 * 1000)
    }
}

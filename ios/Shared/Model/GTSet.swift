//
//  GTSet.swift
//  Runner
//
//  Created by Francesco Arieti on 05/01/26.
//

import Foundation
import SwiftUI

struct GTSet: Codable, Equatable {
    enum Kind: String, Codable {
        case warmUp
        case normal
        case drop
        case failure
        case failureStripping

        var shouldKeepInRoutine: Bool {
            switch self {
            case .failure, .failureStripping:
                return false
            default:
                return true
            }
        }
    }
    
    enum Parameters: String, Codable {
        case repsWeight
        case timeWeight
        case freeBodyReps
        case time
        case distance
        case setless

        var hidden: Bool {
            switch self {
            case .setless:
                return true
            default:
                return false
            }
        }

        var hasReps: Bool {
            self == .repsWeight || self == .freeBodyReps
        }

        var hasWeight: Bool {
            self == .repsWeight || self == .timeWeight
        }

        var hasTime: Bool {
            self == .timeWeight || self == .time
        }

        var hasDistance: Bool {
            self == .distance
        }

        var isSetless: Bool {
            self == .setless
        }
    }
    
    let id: String;
    let kind: Kind;
    let parameters: Parameters;
    let reps: Int?;
    let weight: Double?;
    let time: TimeInterval?;
    let distance: Double?;
    let done: Bool;

    enum CodingKeys: String, CodingKey {
        case id
        case kind
        case parameters
        case reps
        case weight
        case time
        case distance
        case done
    }

    // Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(kind, forKey: .kind)
        try container.encode(parameters, forKey: .parameters)
        try container.encodeIfPresent(reps, forKey: .reps)
        try container.encodeIfPresent(weight, forKey: .weight)
        if let t = time {
            try container.encode(t * 1_000_000, forKey: .time)
        }
        try container.encodeIfPresent(distance, forKey: .distance)
        try container.encode(done, forKey: .done)
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
        id = try container.decode(String.self, forKey: .id)
        kind = try container.decode(Kind.self, forKey: .kind)
        parameters = try container.decode(Parameters.self, forKey: .parameters)
        
        reps = try container.decodeIfPresent(Int.self, forKey: .reps)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        time = (try container.decodeIfPresent(TimeInterval.self, forKey: .time) ?? 0) / 1_000_000
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        done = try container.decode(Bool.self, forKey: .done)
    }
    
    static func decode(fromString string: String) -> GTSet? {
        if let data = string.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return decode(from: dict)
        }
        
        return nil
    }
    
    static func decode(from dictionary: [String?: Any?]) -> GTSet? {
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
            let message = try decoder.decode(GTSet.self, from: jsonData)
            return message
        } catch {
            print("Decoding failed:", error)
            return nil
        }
    }
}

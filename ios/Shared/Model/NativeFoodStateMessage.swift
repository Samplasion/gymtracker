//
//  NativeFoodStateMessage.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//

import Foundation

struct NativeFoodStateMessage: Codable {
    let calorieGoal: Double
    let calorieIntake: Double
    let categories: [NativeFoodCategory]
    let totalNutritionSplit: NativeFoodNutritionSplit

    enum CodingKeys: String, CodingKey {
        case calorieGoal
        case calorieIntake
        case categories
        case totalNutritionSplit
    }
    
    init(calorieGoal: Double, calorieIntake: Double, categories: [NativeFoodCategory], totalNutritionSplit: NativeFoodNutritionSplit) {
        self.calorieGoal = calorieGoal
        self.calorieIntake = calorieIntake
        self.categories = categories
        self.totalNutritionSplit = totalNutritionSplit
    }

    // MARK: - Encoding

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(calorieGoal, forKey: .calorieGoal)
        try container.encode(calorieIntake, forKey: .calorieIntake)
        try container.encode(categories, forKey: .categories)
        try container.encode(totalNutritionSplit, forKey: .totalNutritionSplit)
    }

    func toJSON() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    func toJSONString() throws -> String? {
        if let json = try toJSON(),
           let data = try? JSONSerialization.data(withJSONObject: json),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return nil
    }

    // MARK: - Decoding

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        calorieGoal = try container.decode(Double.self, forKey: .calorieGoal)
        calorieIntake = try container.decode(Double.self, forKey: .calorieIntake)
        categories = try container.decode([NativeFoodCategory].self, forKey: .categories)
        totalNutritionSplit = try container.decode(NativeFoodNutritionSplit.self, forKey: .totalNutritionSplit)
    }

    static func decodeFoodState(from dictionary: [String?: Any?]) -> NativeFoodStateMessage? {
        // Step 1: Sanitize
        var sanitized: [String: Any] = [:]
        for (keyOpt, valueOpt) in dictionary {
            if let key = keyOpt, let value = valueOpt {
                sanitized[key] = value
            }
        }

        // Step 2: JSON Data
        guard JSONSerialization.isValidJSONObject(sanitized),
              let jsonData = try? JSONSerialization.data(withJSONObject: sanitized) else {
            print("Invalid JSON object")
            return nil
        }

        // Step 3: Decode
        do {
            return try JSONDecoder().decode(NativeFoodStateMessage.self, from: jsonData)
        } catch {
            print("Decoding failed:", error)
            return nil
        }
    }

    static func decodeFoodState(fromString string: String) -> NativeFoodStateMessage? {
        guard let data = string.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        return decodeFoodState(from: json)
    }
}

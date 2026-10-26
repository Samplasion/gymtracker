//
//  NativeFoodStateMessage.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//

import Foundation

struct NativeFoodStateMessage: Codable {
    /// Gregorian diary day (yyyy-MM-dd), independent of message delivery.
    let referenceDay: String?
    let generatedAt: Int64?
    let waterIntake: Double?
    let waterGoal: Double?
    let waterOwnerScope: String?
    let waterEntryIds: [String]?
    let calorieGoal: Double
    let calorieIntake: Double
    let categories: [NativeFoodCategory]
    let totalNutritionSplit: NativeFoodNutritionSplit

    enum CodingKeys: String, CodingKey {
        case referenceDay, generatedAt, waterIntake, waterGoal, waterOwnerScope, waterEntryIds
        case calorieGoal
        case calorieIntake
        case categories
        case totalNutritionSplit
    }
    
    init(calorieGoal: Double, calorieIntake: Double, categories: [NativeFoodCategory], totalNutritionSplit: NativeFoodNutritionSplit, referenceDay: String? = nil, generatedAt: Int64? = nil, waterIntake: Double? = nil, waterGoal: Double? = nil, waterOwnerScope: String? = nil, waterEntryIds: [String]? = nil) {
        self.referenceDay = referenceDay
        self.generatedAt = generatedAt
        self.waterIntake = waterIntake
        self.waterGoal = waterGoal
        self.waterOwnerScope = waterOwnerScope
        self.waterEntryIds = waterEntryIds
        self.calorieGoal = calorieGoal
        self.calorieIntake = calorieIntake
        self.categories = categories
        self.totalNutritionSplit = totalNutritionSplit
    }

    // MARK: - Encoding

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(referenceDay, forKey: .referenceDay)
        try container.encodeIfPresent(generatedAt, forKey: .generatedAt)
        try container.encodeIfPresent(waterIntake, forKey: .waterIntake)
        try container.encodeIfPresent(waterGoal, forKey: .waterGoal)
        try container.encodeIfPresent(waterOwnerScope, forKey: .waterOwnerScope)
        try container.encodeIfPresent(waterEntryIds, forKey: .waterEntryIds)
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
        referenceDay = try container.decodeIfPresent(String.self, forKey: .referenceDay)
        generatedAt = try container.decodeIfPresent(Int64.self, forKey: .generatedAt)
        waterIntake = try container.decodeIfPresent(Double.self, forKey: .waterIntake)
        waterGoal = try container.decodeIfPresent(Double.self, forKey: .waterGoal)
        waterOwnerScope = try container.decodeIfPresent(String.self, forKey: .waterOwnerScope)
        waterEntryIds = try container.decodeIfPresent([String].self, forKey: .waterEntryIds)
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

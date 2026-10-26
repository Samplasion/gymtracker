//
//  FoodMessageDelegate.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//

import Foundation

@MainActor
protocol FoodMessageDelegate {
    func acknowledgeWater(ids: Set<String>, ownerScope: String)
    func flushWaterEntries()
    func set(foodParameters: NativeFoodStateMessage)
}

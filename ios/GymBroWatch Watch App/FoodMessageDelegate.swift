//
//  FoodMessageDelegate.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//

@MainActor
protocol FoodMessageDelegate {
    func set(foodParameters: NativeFoodStateMessage)
}

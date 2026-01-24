//
//  TypedApplicationContext.swift
//  Runner
//
//  Created by Francesco Arieti on 27/12/25.
//

import Foundation

struct TypedApplicationContext {
    var isRunning: Bool
    var hasExercise: Bool
    var exerciseName: String?
    var exerciseColor: Int64?
    var exerciseParameters: String?
    var startingTime: Date = Date()
    var restTimeStart: Date?
    var restTimeEnd: Date?
    var percentageDone: Double
    var set: GTSet?
    
    func toDictionary() -> [String: Any] {
        if isRunning {
            return [
                "value": true,
                "hasExercise": hasExercise,
                "exerciseName": exerciseName as Any,
                "exerciseColor": exerciseColor as Any,
                "exerciseParameters": exerciseParameters as Any,
                "startingTime": startingTime as Any,
                "restTimeStart": restTimeStart as Any,
                "restTimeEnd": restTimeEnd as Any,
                "percentageDone": percentageDone as Any,
                "set": set as Any,
            ]
        } else {
            return [
                "value": false
            ]
        }
    }
}

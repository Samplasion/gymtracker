//
//  Int64+Utils.swift
//  Runner
//
//  Created by Francesco Arieti on 27/12/25.
//

import Foundation

extension Int64 {
    var hexString: String {
        return "#" + String(self, radix: 16).padding(toLength: 8, withPad: "0", startingAt: 0).dropFirst(2)
    }
}

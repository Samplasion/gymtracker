//
//  Int64+Color.swift
//  GymBroWatch Watch App
//
//  Created by Francesco Arieti on 26/12/25.
//

import Foundation
import SwiftUI

extension Int64 {
    func asARGBColor() -> Color {
        let b = self & 0xff;
        let g = (self >> 8) & 0xff;
        let r = (self >> 16) & 0xff;
//        let a = (self >> 24) & 0xff;
        
        return Color(red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0, opacity: 1)
    }
}

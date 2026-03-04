//
//  MealLog.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation
import SwiftData

@Model
final class MealLog {
    var foodName: String
    var mealTypeRaw: String
    var timestamp: Date
    var note: String?

    init(foodName: String, mealType: MealType, timestamp: Date, note: String? = nil) {
        self.foodName = foodName
        self.mealTypeRaw = mealType.rawValue
        self.timestamp = timestamp
        self.note = note
    }

    var mealType: MealType {
        get { MealType(rawValue: mealTypeRaw) ?? .lunch }
        set { mealTypeRaw = newValue.rawValue }
    }
}

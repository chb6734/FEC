//
//  FoodItem.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation

struct FoodItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let category: FoodCategory
    let mealTypes: [MealType]
    let restrictions: [DietaryRestriction]
    let tags: [String]
    let baseScore: Double
    let imagePath: String?

    init(id: String, name: String, category: FoodCategory,
         mealTypes: [MealType], restrictions: [DietaryRestriction],
         tags: [String], baseScore: Double, imagePath: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.mealTypes = mealTypes
        self.restrictions = restrictions
        self.tags = tags
        self.baseScore = baseScore
        self.imagePath = imagePath
    }
}

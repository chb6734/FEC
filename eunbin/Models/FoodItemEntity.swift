//
//  FoodItemEntity.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation
import SwiftData

@Model
final class FoodItemEntity {
    @Attribute(.unique) var foodId: String
    var name: String
    var categoryRaw: String
    var mealTypesRaw: [String]
    var restrictionsRaw: [String]
    var tags: [String]
    var baseScore: Double
    var imagePath: String?

    init(foodId: String, name: String, category: FoodCategory,
         mealTypes: [MealType], restrictions: [DietaryRestriction],
         tags: [String], baseScore: Double, imagePath: String? = nil) {
        self.foodId = foodId
        self.name = name
        self.categoryRaw = category.rawValue
        self.mealTypesRaw = mealTypes.map(\.rawValue)
        self.restrictionsRaw = restrictions.map(\.rawValue)
        self.tags = tags
        self.baseScore = baseScore
        self.imagePath = imagePath
    }

    var category: FoodCategory {
        FoodCategory(rawValue: categoryRaw) ?? .other
    }

    var mealTypes: [MealType] {
        mealTypesRaw.compactMap { MealType(rawValue: $0) }
    }

    var restrictions: [DietaryRestriction] {
        restrictionsRaw.compactMap { DietaryRestriction(rawValue: $0) }
    }

    func toFoodItem() -> FoodItem {
        FoodItem(
            id: foodId,
            name: name,
            category: category,
            mealTypes: mealTypes,
            restrictions: restrictions,
            tags: tags,
            baseScore: baseScore,
            imagePath: imagePath
        )
    }
}

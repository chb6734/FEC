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
}

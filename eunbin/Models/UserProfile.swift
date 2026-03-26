//
//  UserProfile.swift
//  FEC
//
//  Created by Dohyun iOS Engineer
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var mealPatternRaw: [String] = []
    var restrictionsRaw: [String] = []
    var preferredCategoriesRaw: [String] = []
    var dislikes: [String] = []
    var hasCompletedOnboarding: Bool = false
    var customMealTimeStart: String?
    var customMealTimeEnd: String?
    var budgetRaw: String?

    init() {}

    var budget: BudgetRange? {
        get { budgetRaw.flatMap { BudgetRange(rawValue: $0) } }
        set { budgetRaw = newValue?.rawValue }
    }

    var mealPattern: [MealType] {
        get { mealPatternRaw.compactMap { MealType(rawValue: $0) } }
        set { mealPatternRaw = newValue.map(\.rawValue) }
    }

    var restrictions: [DietaryRestriction] {
        get { restrictionsRaw.compactMap { DietaryRestriction(rawValue: $0) } }
        set { restrictionsRaw = newValue.map(\.rawValue) }
    }

    var preferredCategories: [FoodCategory] {
        get { preferredCategoriesRaw.compactMap { FoodCategory(rawValue: $0) } }
        set { preferredCategoriesRaw = newValue.map(\.rawValue) }
    }
}

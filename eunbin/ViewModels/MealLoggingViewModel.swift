//
//  MealLoggingViewModel.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class MealLoggingViewModel {
    var foodName: String
    var selectedMealType: MealType
    var note: String = ""
    var isSaved: Bool = false
    let isFromRecommendation: Bool

    var canSave: Bool {
        !foodName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(food: FoodItem? = nil) {
        if let food {
            self.foodName = food.name
            self.isFromRecommendation = true
        } else {
            self.foodName = ""
            self.isFromRecommendation = false
        }
        self.selectedMealType = MealType.current()
    }

    func save(to modelContext: ModelContext) {
        guard canSave else { return }
        let log = MealLog(
            foodName: foodName.trimmingCharacters(in: .whitespaces),
            mealType: selectedMealType,
            timestamp: Date(),
            note: note.isEmpty ? nil : note
        )
        modelContext.insert(log)
        isSaved = true
    }
}

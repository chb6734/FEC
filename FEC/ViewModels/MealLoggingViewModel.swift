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

    private let supabaseService = SupabaseService()

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
        let trimmedName = foodName.trimmingCharacters(in: .whitespaces)
        let noteValue = note.isEmpty ? nil : note

        // 로컬 SwiftData 저장
        let log = MealLog(
            foodName: trimmedName,
            mealType: selectedMealType,
            timestamp: Date(),
            note: noteValue
        )
        modelContext.insert(log)
        isSaved = true

        // Supabase에 동기화
        Task {
            do {
                try await supabaseService.insertMealLog(
                    foodName: trimmedName,
                    mealType: selectedMealType,
                    note: noteValue
                )
            } catch {
                print("Failed to sync meal log to Supabase: \(error)")
            }
        }
    }
}

//
//  SettingsViewModel.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    var selectedMealPatterns: Set<MealType> = []
    var selectedRestrictions: Set<DietaryRestriction> = []
    var selectedCategories: Set<FoodCategory> = []
    var dislikeText: String = ""

    var canSave: Bool {
        !selectedMealPatterns.isEmpty &&
        !selectedRestrictions.isEmpty &&
        !selectedCategories.isEmpty
    }

    var parsedDislikes: [String] {
        guard !dislikeText.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        return dislikeText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    func loadFrom(profile: UserProfile) {
        selectedMealPatterns = Set(profile.mealPattern)
        selectedRestrictions = Set(profile.restrictions)
        selectedCategories = Set(profile.preferredCategories)
        dislikeText = profile.dislikes.joined(separator: ", ")
    }

    func hasChanges(from profile: UserProfile) -> Bool {
        Set(profile.mealPattern) != selectedMealPatterns ||
        Set(profile.restrictions) != selectedRestrictions ||
        Set(profile.preferredCategories) != selectedCategories ||
        profile.dislikes != parsedDislikes
    }

    func save(to profile: UserProfile) {
        profile.mealPattern = Array(selectedMealPatterns)
        profile.restrictions = Array(selectedRestrictions)
        profile.preferredCategories = Array(selectedCategories)
        profile.dislikes = parsedDislikes
    }
}

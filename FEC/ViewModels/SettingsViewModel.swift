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

    private let supabaseService = SupabaseService()

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
        // 로컬 SwiftData 업데이트
        profile.mealPattern = Array(selectedMealPatterns)
        profile.restrictions = Array(selectedRestrictions)
        profile.preferredCategories = Array(selectedCategories)
        profile.dislikes = parsedDislikes

        // Supabase에 동기화
        Task {
            await syncProfileToSupabase()
        }
    }

    func signOut() async throws {
        try await supabaseService.signOut()
    }

    private func syncProfileToSupabase() async {
        guard let userId = await supabaseService.currentUserId() else { return }
        let profile = SupabaseProfile(
            id: userId,
            mealPatterns: selectedMealPatterns.map(\.rawValue),
            restrictions: selectedRestrictions.map(\.rawValue),
            preferredCategories: selectedCategories.map(\.rawValue),
            dislikes: parsedDislikes,
            budget: nil,
            hasCompletedOnboarding: true
        )
        do {
            try await supabaseService.updateProfile(profile)
        } catch {
            print("Failed to sync settings to Supabase: \(error)")
        }
    }
}

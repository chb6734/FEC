//
//  RecommendationViewModel.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class RecommendationViewModel {
    var recommendations: [FoodItem] = []
    var currentMealType: MealType = .lunch
    var currentCardIndex: Int = 0
    var selectedFoods: [FoodItem] = []

    private let engine = RecommendationEngine()
    private var foodDataService: FoodDataService?
    private let supabaseService = SupabaseService()

    var currentCard: FoodItem? {
        guard currentCardIndex < recommendations.count else { return nil }
        return recommendations[currentCardIndex]
    }

    var hasReviewedAllCards: Bool {
        currentCardIndex >= recommendations.count && !recommendations.isEmpty
    }

    func advanceCard() {
        if currentCardIndex < recommendations.count {
            // 스킵한 카드를 selection_log에 기록
            if let card = currentCard {
                Task {
                    try? await supabaseService.insertSelectionLog(
                        foodId: card.id,
                        mealType: currentMealType,
                        isSelected: false
                    )
                }
            }
            currentCardIndex += 1
        }
    }

    func selectFood(_ food: FoodItem) {
        if !selectedFoods.contains(where: { $0.id == food.id }) {
            selectedFoods.append(food)
            // 선택한 카드를 selection_log에 기록
            Task {
                try? await supabaseService.insertSelectionLog(
                    foodId: food.id,
                    mealType: currentMealType,
                    isSelected: true
                )
            }
        }
    }

    func configure(modelContext: ModelContext) {
        if foodDataService == nil {
            foodDataService = FoodDataService(modelContext: modelContext)
        }
    }

    func loadRecommendations(profile: UserProfile?, logs: [MealLog], feedbacks: [FeedbackRecord]) {
        currentMealType = MealType.current()
        currentCardIndex = 0
        selectedFoods = []
        reloadCards(profile: profile, logs: logs, feedbacks: feedbacks)
    }

    func switchMealType(_ type: MealType, profile: UserProfile?, logs: [MealLog], feedbacks: [FeedbackRecord]) {
        currentMealType = type
        currentCardIndex = 0
        selectedFoods = []
        reloadCards(profile: profile, logs: logs, feedbacks: feedbacks)
    }

    private func reloadCards(profile: UserProfile?, logs: [MealLog], feedbacks: [FeedbackRecord]) {
        guard let profile else {
            recommendations = []
            return
        }

        let profileData = ProfileData(
            mealPattern: profile.mealPattern,
            restrictions: profile.restrictions,
            preferredCategories: profile.preferredCategories,
            dislikes: profile.dislikes
        )

        let recentLogs = logs.map { RecentLog(foodName: $0.foodName, date: $0.timestamp) }
        let feedbackEntries = feedbacks.map { FeedbackEntry(foodId: $0.foodId, isLiked: $0.isLiked) }

        Task {
            let allFoods = await fetchFoods()
            recommendations = engine.recommend(
                for: currentMealType,
                profile: profileData,
                recentLogs: recentLogs,
                feedbacks: feedbackEntries,
                allFoods: allFoods
            )
        }
    }

    private func fetchFoods() async -> [FoodItem] {
        // Supabase 우선, 실패 시 로컬 폴백
        do {
            let supabaseFoods = try await supabaseService.fetchAllFoods()
            if !supabaseFoods.isEmpty {
                return supabaseFoods.map { $0.toFoodItem() }
            }
        } catch {
            print("Supabase fetch failed, using local: \(error)")
        }

        // 로컬 SwiftData 폴백
        if let service = foodDataService,
           let entities = try? service.fetchAllFoods() {
            return entities.map { $0.toFoodItem() }
        }

        return FoodDatabase.allFoods
    }

    func refresh(profile: UserProfile?, logs: [MealLog], feedbacks: [FeedbackRecord]) {
        loadRecommendations(profile: profile, logs: logs, feedbacks: feedbacks)
    }
}

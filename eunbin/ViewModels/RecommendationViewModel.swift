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

    var currentCard: FoodItem? {
        guard currentCardIndex < recommendations.count else { return nil }
        return recommendations[currentCardIndex]
    }

    var hasReviewedAllCards: Bool {
        currentCardIndex >= recommendations.count && !recommendations.isEmpty
    }

    func advanceCard() {
        if currentCardIndex < recommendations.count {
            currentCardIndex += 1
        }
    }

    func selectFood(_ food: FoodItem) {
        if !selectedFoods.contains(where: { $0.id == food.id }) {
            selectedFoods.append(food)
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

        // Fetch foods from SwiftData, fallback to FoodDatabase
        let allFoods: [FoodItem]
        if let service = foodDataService,
           let entities = try? service.fetchAllFoods() {
            allFoods = entities.map { $0.toFoodItem() }
        } else {
            allFoods = FoodDatabase.allFoods
        }

        recommendations = engine.recommend(
            for: currentMealType,
            profile: profileData,
            recentLogs: recentLogs,
            feedbacks: feedbackEntries,
            allFoods: allFoods
        )
    }

    func refresh(profile: UserProfile?, logs: [MealLog], feedbacks: [FeedbackRecord]) {
        loadRecommendations(profile: profile, logs: logs, feedbacks: feedbacks)
    }
}

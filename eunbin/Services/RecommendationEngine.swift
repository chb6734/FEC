//
//  RecommendationEngine.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation

struct ProfileData {
    let mealPattern: [MealType]
    let restrictions: [DietaryRestriction]
    let preferredCategories: [FoodCategory]
    var dislikes: [String]
}

struct RecentLog {
    let foodName: String
    let date: Date
}

struct FeedbackEntry {
    let foodId: String
    let isLiked: Bool
}

final class RecommendationEngine {
    private let maxResults = 5
    private let recentAvoidanceDays = 3

    func recommend(
        for mealType: MealType,
        profile: ProfileData,
        recentLogs: [RecentLog],
        feedbacks: [FeedbackEntry],
        allFoods: [FoodItem]
    ) -> [FoodItem] {

        // 1. Filter by meal type
        var candidates = allFoods.filter { $0.mealTypes.contains(mealType) }

        // 2. Filter by dietary restrictions
        let hasRestriction = !profile.restrictions.contains(.none) && !profile.restrictions.isEmpty
        if hasRestriction {
            candidates = candidates.filter { food in
                profile.restrictions.allSatisfy { restriction in
                    food.restrictions.contains(restriction)
                }
            }
        }

        // 3. Filter out dislikes
        let loweredDislikes = Set(profile.dislikes.map { $0.lowercased() })
        if !loweredDislikes.isEmpty {
            candidates = candidates.filter { food in
                !loweredDislikes.contains(food.name.lowercased())
            }
        }

        // 4. Filter out recently eaten (within recentAvoidanceDays)
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -recentAvoidanceDays, to: Date()) ?? Date()
        let recentNames = Set(
            recentLogs
                .filter { $0.date >= cutoffDate }
                .map { $0.foodName }
        )
        candidates = candidates.filter { !recentNames.contains($0.name) }

        // 5. Score and sort
        let feedbackMap = Dictionary(feedbacks.map { ($0.foodId, $0.isLiked) }, uniquingKeysWith: { _, last in last })
        let preferredSet = Set(profile.preferredCategories)

        let scored = candidates.map { food -> (FoodItem, Double) in
            var score = food.baseScore

            // Category preference bonus
            if preferredSet.contains(food.category) {
                score += 0.5
            }

            // Feedback adjustment
            if let liked = feedbackMap[food.id] {
                score += liked ? 0.3 : -0.5
            }

            return (food, score)
        }

        let sorted = scored
            .sorted { $0.1 > $1.1 }
            .map(\.0)

        return Array(sorted.prefix(maxResults))
    }
}

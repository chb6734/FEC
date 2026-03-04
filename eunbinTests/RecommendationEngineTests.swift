//
//  RecommendationEngineTests.swift
//  eunbinTests
//
//  Created by Dohyun iOS Engineer
//

import Testing
import Foundation
@testable import eunbin

struct RecommendationEngineTests {

    // MARK: - Time-based Filtering

    @Test func filtersByMealType() {
        let engine = RecommendationEngine()
        let profile = makeProfile(mealPattern: [.lunch], restrictions: [.none], categories: FoodCategory.allCases)
        let results = engine.recommend(for: .lunch, profile: profile, recentLogs: [], feedbacks: [], allFoods: FoodDatabase.allFoods)
        for food in results {
            #expect(food.mealTypes.contains(.lunch))
        }
    }

    @Test func returnsMaxFiveItems() {
        let engine = RecommendationEngine()
        let profile = makeProfile(mealPattern: [.lunch], restrictions: [.none], categories: FoodCategory.allCases)
        let results = engine.recommend(for: .lunch, profile: profile, recentLogs: [], feedbacks: [], allFoods: FoodDatabase.allFoods)
        #expect(results.count <= 5)
        #expect(results.count >= 1)
    }

    // MARK: - Restriction Filtering

    @Test func filtersVegetarianRestriction() {
        let engine = RecommendationEngine()
        let profile = makeProfile(mealPattern: [.lunch], restrictions: [.vegetarian], categories: FoodCategory.allCases)
        let results = engine.recommend(for: .lunch, profile: profile, recentLogs: [], feedbacks: [], allFoods: FoodDatabase.allFoods)
        for food in results {
            #expect(food.restrictions.contains(.vegetarian))
        }
    }

    @Test func filtersLowCalorie() {
        let engine = RecommendationEngine()
        let profile = makeProfile(mealPattern: [.lunch], restrictions: [.lowCalorie], categories: FoodCategory.allCases)
        let results = engine.recommend(for: .lunch, profile: profile, recentLogs: [], feedbacks: [], allFoods: FoodDatabase.allFoods)
        for food in results {
            #expect(food.restrictions.contains(.lowCalorie))
        }
    }

    @Test func noneRestrictionShowsAll() {
        let engine = RecommendationEngine()
        let profile = makeProfile(mealPattern: [.lunch], restrictions: [.none], categories: FoodCategory.allCases)
        let results = engine.recommend(for: .lunch, profile: profile, recentLogs: [], feedbacks: [], allFoods: FoodDatabase.allFoods)
        #expect(results.count >= 1)
    }

    // MARK: - Category Preference

    @Test func preferredCategoriesRankHigher() {
        let engine = RecommendationEngine()
        let profile = makeProfile(mealPattern: [.lunch], restrictions: [.none], categories: [.korean])
        let results = engine.recommend(for: .lunch, profile: profile, recentLogs: [], feedbacks: [], allFoods: FoodDatabase.allFoods)
        if let first = results.first {
            #expect(first.category == .korean)
        }
    }

    // MARK: - Recent Log Avoidance

    @Test func avoidsRecentlyEaten() {
        let engine = RecommendationEngine()
        let profile = makeProfile(mealPattern: [.lunch], restrictions: [.none], categories: FoodCategory.allCases)
        let recentLogs = [
            RecentLog(foodName: "비빔밥", date: Date()),
            RecentLog(foodName: "김치찌개", date: Date()),
        ]
        let results = engine.recommend(for: .lunch, profile: profile, recentLogs: recentLogs, feedbacks: [], allFoods: FoodDatabase.allFoods)
        let names = results.map(\.name)
        #expect(!names.contains("비빔밥"))
        #expect(!names.contains("김치찌개"))
    }

    // MARK: - Dislike Filtering

    @Test func filtersDislikes() {
        let engine = RecommendationEngine()
        var profile = makeProfile(mealPattern: [.lunch], restrictions: [.none], categories: FoodCategory.allCases)
        profile.dislikes = ["비빔밥"]
        let results = engine.recommend(for: .lunch, profile: profile, recentLogs: [], feedbacks: [], allFoods: FoodDatabase.allFoods)
        let names = results.map(\.name)
        #expect(!names.contains("비빔밥"))
    }

    // MARK: - Feedback Integration

    @Test func negativeFeedbackLowersScore() {
        let engine = RecommendationEngine()
        let profile = makeProfile(mealPattern: [.lunch], restrictions: [.none], categories: FoodCategory.allCases)
        let feedbacks = [FeedbackEntry(foodId: "bibimbap", isLiked: false)]
        let results = engine.recommend(for: .lunch, profile: profile, recentLogs: [], feedbacks: feedbacks, allFoods: FoodDatabase.allFoods)
        // 비빔밥이 있다면 상위 순위가 아닐 것
        if let index = results.firstIndex(where: { $0.id == "bibimbap" }) {
            #expect(index > 0) // not first
        }
    }

    // MARK: - Shuffle / Variety

    @Test func recommendationsAreNotEmpty() {
        let engine = RecommendationEngine()
        let profile = makeProfile(mealPattern: [.breakfast, .lunch, .dinner], restrictions: [.none], categories: FoodCategory.allCases)
        for mealType in MealType.allCases {
            let results = engine.recommend(for: mealType, profile: profile, recentLogs: [], feedbacks: [], allFoods: FoodDatabase.allFoods)

            #expect(!results.isEmpty, "Should have recommendations for \(mealType.displayName)")
        }
    }

    // MARK: - Helpers

    private func makeProfile(mealPattern: [MealType], restrictions: [DietaryRestriction], categories: [FoodCategory]) -> ProfileData {
        ProfileData(mealPattern: mealPattern, restrictions: restrictions, preferredCategories: categories, dislikes: [])
    }
}

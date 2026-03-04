//
//  FoodDataServiceTests.swift
//  eunbinTests
//
//  Created by Dohyun iOS Engineer
//

import Testing
import Foundation
import SwiftData
@testable import eunbin

@MainActor
struct FoodDataServiceTests {

    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: FoodItemEntity.self, UserProfile.self, MealLog.self, FeedbackRecord.self,
            configurations: config
        )
    }

    // MARK: - Seeding

    @Test func seedsFromJSON() throws {
        let container = try makeContainer()
        let service = FoodDataService(modelContext: container.mainContext)
        try service.seedIfNeeded()

        let descriptor = FetchDescriptor<FoodItemEntity>()
        let count = try container.mainContext.fetchCount(descriptor)
        #expect(count >= 200)
    }

    @Test func seedIsIdempotent() throws {
        let container = try makeContainer()
        let service = FoodDataService(modelContext: container.mainContext)
        try service.seedIfNeeded()
        try service.seedIfNeeded() // second call should not duplicate

        let descriptor = FetchDescriptor<FoodItemEntity>()
        let count = try container.mainContext.fetchCount(descriptor)
        #expect(count >= 200)
        #expect(count < 400) // no duplicates
    }

    // MARK: - Queries

    @Test func fetchAllFoods() throws {
        let container = try makeContainer()
        let service = FoodDataService(modelContext: container.mainContext)
        try service.seedIfNeeded()

        let foods = try service.fetchAllFoods()
        #expect(foods.count >= 200)
    }

    @Test func fetchByMealType() throws {
        let container = try makeContainer()
        let service = FoodDataService(modelContext: container.mainContext)
        try service.seedIfNeeded()

        let lunchFoods = try service.fetchFoods(for: .lunch)
        #expect(!lunchFoods.isEmpty)
        for food in lunchFoods {
            #expect(food.mealTypes.contains(.lunch))
        }
    }

    @Test func fetchByCategory() throws {
        let container = try makeContainer()
        let service = FoodDataService(modelContext: container.mainContext)
        try service.seedIfNeeded()

        let koreanFoods = try service.fetchFoods(category: .korean)
        #expect(!koreanFoods.isEmpty)
        for food in koreanFoods {
            #expect(food.category == .korean)
        }
    }

    @Test func uniqueIds() throws {
        let container = try makeContainer()
        let service = FoodDataService(modelContext: container.mainContext)
        try service.seedIfNeeded()

        let foods = try service.fetchAllFoods()
        let ids = foods.map(\.foodId)
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
    }

    @Test func allCategoriesPresent() throws {
        let container = try makeContainer()
        let service = FoodDataService(modelContext: container.mainContext)
        try service.seedIfNeeded()

        let foods = try service.fetchAllFoods()
        let categories = Set(foods.map(\.category))
        #expect(categories.contains(.korean))
        #expect(categories.contains(.chinese))
        #expect(categories.contains(.japanese))
        #expect(categories.contains(.western))
        #expect(categories.contains(.snack))
    }

    @Test func allMealTypesPresent() throws {
        let container = try makeContainer()
        let service = FoodDataService(modelContext: container.mainContext)
        try service.seedIfNeeded()

        let foods = try service.fetchAllFoods()
        let hasBreakfast = foods.contains { $0.mealTypes.contains(.breakfast) }
        let hasLunch = foods.contains { $0.mealTypes.contains(.lunch) }
        let hasDinner = foods.contains { $0.mealTypes.contains(.dinner) }
        #expect(hasBreakfast)
        #expect(hasLunch)
        #expect(hasDinner)
    }
}

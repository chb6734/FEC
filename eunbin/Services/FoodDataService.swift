//
//  FoodDataService.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation
import SwiftData

final class FoodDataService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Seeding

    func seedIfNeeded() throws {
        let descriptor = FetchDescriptor<FoodItemEntity>()
        let existingCount = try modelContext.fetchCount(descriptor)
        guard existingCount == 0 else { return }

        let foods = try loadFoodsFromJSON()
        for food in foods {
            let entity = FoodItemEntity(
                foodId: food.id,
                name: food.name,
                category: food.category,
                mealTypes: food.mealTypes,
                restrictions: food.restrictions,
                tags: food.tags,
                baseScore: food.baseScore
            )
            modelContext.insert(entity)
        }
        try modelContext.save()
    }

    // MARK: - Queries

    func fetchAllFoods() throws -> [FoodItemEntity] {
        let descriptor = FetchDescriptor<FoodItemEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchFoods(for mealType: MealType) throws -> [FoodItemEntity] {
        let allFoods = try fetchAllFoods()
        return allFoods.filter { $0.mealTypes.contains(mealType) }
    }

    func fetchFoods(category: FoodCategory) throws -> [FoodItemEntity] {
        let raw = category.rawValue
        let predicate = #Predicate<FoodItemEntity> { $0.categoryRaw == raw }
        let descriptor = FetchDescriptor<FoodItemEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - JSON Loading

    private func loadFoodsFromJSON() throws -> [FoodItem] {
        guard let url = Bundle.main.url(forResource: "foods", withExtension: "json") else {
            throw FoodDataError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([FoodItem].self, from: data)
    }
}

enum FoodDataError: Error {
    case fileNotFound
}

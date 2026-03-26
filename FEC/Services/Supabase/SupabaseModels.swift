//
//  SupabaseModels.swift
//  eunbin
//
//  Supabase 테이블과 매핑되는 Codable DTO
//

import Foundation

// MARK: - Food Category

struct SupabaseFoodCategory: Codable, Identifiable {
    let id: String
    let displayName: String
    let emoji: String
    let themeColor: String
    let sortOrder: Int
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case emoji
        case themeColor = "theme_color"
        case sortOrder = "sort_order"
        case isActive = "is_active"
    }
}

// MARK: - Profile

struct SupabaseProfile: Codable {
    let id: UUID
    var mealPatterns: [String]
    var restrictions: [String]
    var preferredCategories: [String]
    var dislikes: [String]
    var budget: String?
    var hasCompletedOnboarding: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case mealPatterns = "meal_patterns"
        case restrictions
        case preferredCategories = "preferred_categories"
        case dislikes
        case budget
        case hasCompletedOnboarding = "has_completed_onboarding"
    }
}

// MARK: - Food

struct SupabaseFood: Codable, Identifiable {
    let id: String
    let name: String
    let category: String
    let mealTypes: [String]
    let restrictions: [String]
    let tags: [String]
    let baseScore: Double
    let imageUrl: String?
    let imageUrlWhite: String?
    let imageUrlBlue: String?

    enum CodingKeys: String, CodingKey {
        case id, name, category, restrictions, tags
        case mealTypes = "meal_types"
        case baseScore = "base_score"
        case imageUrl = "image_url"
        case imageUrlWhite = "image_url_white"
        case imageUrlBlue = "image_url_blue"
    }

    func toFoodItem() -> FoodItem {
        FoodItem(
            id: id,
            name: name,
            category: FoodCategory(rawValue: category) ?? .other,
            mealTypes: mealTypes.compactMap { MealType(rawValue: $0) },
            restrictions: restrictions.compactMap { DietaryRestriction(rawValue: $0) },
            tags: tags,
            baseScore: baseScore,
            imagePath: imageUrl,
            imageUrlWhite: imageUrlWhite,
            imageUrlBlue: imageUrlBlue
        )
    }
}

// MARK: - Meal Log

struct SupabaseMealLog: Codable {
    var id: UUID?
    let userId: UUID
    let foodName: String
    let mealType: String
    let note: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case foodName = "food_name"
        case mealType = "meal_type"
        case note
        case createdAt = "created_at"
    }
}

// MARK: - Feedback

struct SupabaseFeedback: Codable {
    var id: UUID?
    let userId: UUID
    let foodId: String
    var isLiked: Bool
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case foodId = "food_id"
        case isLiked = "is_liked"
        case createdAt = "created_at"
    }
}

// MARK: - Selection Log (추천 알고리즘용)

struct SupabaseSelectionLog: Codable {
    var id: UUID?
    let userId: UUID
    let foodId: String
    let mealType: String
    var moodScore: Double?
    var weather: String?
    var temperature: Double?
    var timeOfDay: String?
    var dayOfWeek: Int?
    var isSelected: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case foodId = "food_id"
        case mealType = "meal_type"
        case moodScore = "mood_score"
        case weather
        case temperature
        case timeOfDay = "time_of_day"
        case dayOfWeek = "day_of_week"
        case isSelected = "is_selected"
    }
}

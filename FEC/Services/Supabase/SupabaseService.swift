//
//  SupabaseService.swift
//  FEC
//
//  Supabase CRUD 서비스 (Auth, Foods, MealLogs, Feedbacks, SelectionLogs)
//

import Foundation
import Supabase

@MainActor
final class SupabaseService {
    private let client = SupabaseManager.shared.client

    // MARK: - Auth

    func currentUserId() async -> UUID? {
        try? await client.auth.session.user.id
    }

    func isAuthenticated() async -> Bool {
        await currentUserId() != nil
    }

    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    // MARK: - Profile

    func fetchProfile() async throws -> SupabaseProfile? {
        guard let userId = await currentUserId() else { return nil }
        let response: [SupabaseProfile] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .execute()
            .value
        return response.first
    }

    func updateProfile(_ profile: SupabaseProfile) async throws {
        try await client
            .from("profiles")
            .update(profile)
            .eq("id", value: profile.id.uuidString)
            .execute()
    }

    // MARK: - Foods

    func fetchAllFoods() async throws -> [SupabaseFood] {
        let response: [SupabaseFood] = try await client
            .from("foods")
            .select()
            .order("name")
            .execute()
            .value
        return response
    }

    func fetchFoods(category: String) async throws -> [SupabaseFood] {
        let response: [SupabaseFood] = try await client
            .from("foods")
            .select()
            .eq("category", value: category)
            .order("name")
            .execute()
            .value
        return response
    }

    // MARK: - Meal Logs

    func fetchMealLogs() async throws -> [SupabaseMealLog] {
        guard let userId = await currentUserId() else { return [] }
        let response: [SupabaseMealLog] = try await client
            .from("meal_logs")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        return response
    }

    func insertMealLog(foodName: String, mealType: MealType, note: String?) async throws {
        guard let userId = await currentUserId() else { return }
        let log = SupabaseMealLog(
            userId: userId,
            foodName: foodName,
            mealType: mealType.rawValue,
            note: note,
            createdAt: nil
        )
        try await client
            .from("meal_logs")
            .insert(log)
            .execute()
    }

    // MARK: - Feedbacks

    func fetchFeedbacks() async throws -> [SupabaseFeedback] {
        guard let userId = await currentUserId() else { return [] }
        let response: [SupabaseFeedback] = try await client
            .from("feedbacks")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        return response
    }

    func upsertFeedback(foodId: String, isLiked: Bool) async throws {
        guard let userId = await currentUserId() else { return }
        let feedback = SupabaseFeedback(
            userId: userId,
            foodId: foodId,
            isLiked: isLiked,
            createdAt: nil
        )
        try await client
            .from("feedbacks")
            .upsert(feedback, onConflict: "user_id,food_id")
            .execute()
    }

    // MARK: - Selection Logs (추천 알고리즘용)

    func insertSelectionLog(
        foodId: String,
        mealType: MealType,
        isSelected: Bool,
        moodScore: Double? = nil,
        weather: String? = nil,
        temperature: Double? = nil
    ) async throws {
        guard let userId = await currentUserId() else { return }

        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)
        let dayOfWeek = Calendar.current.component(.weekday, from: now)

        let timeOfDay: String
        switch hour {
        case 6..<12: timeOfDay = "morning"
        case 12..<18: timeOfDay = "afternoon"
        default: timeOfDay = "evening"
        }

        let log = SupabaseSelectionLog(
            userId: userId,
            foodId: foodId,
            mealType: mealType.rawValue,
            moodScore: moodScore,
            weather: weather,
            temperature: temperature,
            timeOfDay: timeOfDay,
            dayOfWeek: dayOfWeek,
            isSelected: isSelected
        )
        try await client
            .from("selection_logs")
            .insert(log)
            .execute()
    }

    func fetchSelectionLogs(limit: Int = 100) async throws -> [SupabaseSelectionLog] {
        guard let userId = await currentUserId() else { return [] }
        let response: [SupabaseSelectionLog] = try await client
            .from("selection_logs")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
        return response
    }

    // MARK: - Food Image Storage

    func uploadFoodImage(foodId: String, imageData: Data) async throws -> String {
        let path = "foods/\(foodId).jpg"
        try await client.storage
            .from("food-images")
            .upload(path, data: imageData, options: .init(contentType: "image/jpeg", upsert: true))

        let publicURL = try client.storage
            .from("food-images")
            .getPublicURL(path: path)

        // 음식 테이블의 image_url 업데이트
        try await client
            .from("foods")
            .update(["image_url": publicURL.absoluteString])
            .eq("id", value: foodId)
            .execute()

        return publicURL.absoluteString
    }

    func getFoodImageURL(foodId: String) throws -> URL {
        let path = "foods/\(foodId).jpg"
        return try client.storage
            .from("food-images")
            .getPublicURL(path: path)
    }

    // MARK: - Seed Foods (로컬 JSON → Supabase 업로드)

    func seedFoodsFromJSON() async throws {
        // 이미 데이터가 있는지 확인
        let existing: [SupabaseFood] = try await client
            .from("foods")
            .select()
            .limit(1)
            .execute()
            .value

        guard existing.isEmpty else { return }

        // JSON 파일에서 음식 데이터 로드
        guard let url = Bundle.main.url(forResource: "foods", withExtension: "json") else {
            throw FoodDataError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        let foods = try JSONDecoder().decode([FoodItem].self, from: data)

        // Supabase 형식으로 변환
        let supabaseFoods = foods.map { food in
            SupabaseFood(
                id: food.id,
                name: food.name ,
                category: food.category.rawValue,
                mealTypes: food.mealTypes.map(\.rawValue),
                restrictions: food.restrictions.map(\.rawValue),
                tags: food.tags,
                baseScore: food.baseScore,
                imageUrl: food.imagePath,
                imageUrlWhite: food.imageUrlWhite,
                imageUrlBlue: food.imageUrlBlue
            )
        }

        // 50개씩 배치 삽입
        let batchSize = 50
        for batchStart in stride(from: 0, to: supabaseFoods.count, by: batchSize) {
            let batchEnd = min(batchStart + batchSize, supabaseFoods.count)
            let batch = Array(supabaseFoods[batchStart..<batchEnd])
            try await client
                .from("foods")
                .insert(batch)
                .execute()
        }
    }
}

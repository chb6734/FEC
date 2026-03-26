//
//  FeedbackViewModel.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class FeedbackViewModel {
    var pendingFeedbacks: [String: Bool] = [:]

    private let supabaseService = SupabaseService()

    func toggleFeedback(foodId: String, isLiked: Bool, feedbacks: [FeedbackRecord]) {
        let currentValue = getFeedback(for: foodId, in: feedbacks)
        if currentValue == isLiked {
            pendingFeedbacks.removeValue(forKey: foodId)
        } else {
            pendingFeedbacks[foodId] = isLiked
        }
    }

    func getFeedback(for foodId: String) -> Bool? {
        pendingFeedbacks[foodId]
    }

    func getFeedback(for foodId: String, in feedbacks: [FeedbackRecord]) -> Bool? {
        if let pending = pendingFeedbacks[foodId] {
            return pending
        }
        return feedbacks.first(where: { $0.foodId == foodId })?.isLiked
    }

    func savePendingFeedbacks(to modelContext: ModelContext, existing: [FeedbackRecord]) {
        // 로컬 SwiftData 저장
        for (foodId, isLiked) in pendingFeedbacks {
            if let existing = existing.first(where: { $0.foodId == foodId }) {
                existing.isLiked = isLiked
                existing.timestamp = Date()
            } else {
                let record = FeedbackRecord(foodId: foodId, isLiked: isLiked)
                modelContext.insert(record)
            }
        }

        // Supabase에 동기화
        let feedbacksCopy = pendingFeedbacks
        Task {
            for (foodId, isLiked) in feedbacksCopy {
                do {
                    try await supabaseService.upsertFeedback(foodId: foodId, isLiked: isLiked)
                } catch {
                    print("Failed to sync feedback to Supabase: \(error)")
                }
            }
        }

        pendingFeedbacks.removeAll()
    }
}

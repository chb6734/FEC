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
        for (foodId, isLiked) in pendingFeedbacks {
            if let existing = existing.first(where: { $0.foodId == foodId }) {
                existing.isLiked = isLiked
                existing.timestamp = Date()
            } else {
                let record = FeedbackRecord(foodId: foodId, isLiked: isLiked)
                modelContext.insert(record)
            }
        }
        pendingFeedbacks.removeAll()
    }
}

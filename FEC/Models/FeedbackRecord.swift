//
//  FeedbackRecord.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation
import SwiftData

@Model
final class FeedbackRecord {
    var foodId: String
    var isLiked: Bool
    var timestamp: Date

    init(foodId: String, isLiked: Bool, timestamp: Date = Date()) {
        self.foodId = foodId
        self.isLiked = isLiked
        self.timestamp = timestamp
    }
}

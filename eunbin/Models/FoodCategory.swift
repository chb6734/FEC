//
//  FoodCategory.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation

enum FoodCategory: String, Codable, CaseIterable, Identifiable {
    case korean
    case chinese
    case japanese
    case western
    case snack
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .korean: "한식"
        case .chinese: "중식"
        case .japanese: "일식"
        case .western: "양식"
        case .snack: "분식"
        case .other: "기타"
        }
    }

    var emoji: String {
        switch self {
        case .korean: "🇰🇷"
        case .chinese: "🇨🇳"
        case .japanese: "🇯🇵"
        case .western: "🍝"
        case .snack: "🍢"
        case .other: "🍽️"
        }
    }
}

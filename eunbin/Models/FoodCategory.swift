//
//  FoodCategory.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation
import SwiftUI

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

    var themeColor: Color {
        switch self {
        case .korean: .orange
        case .chinese: .red
        case .japanese: .pink
        case .western: .blue
        case .snack: .yellow
        case .other: .purple
        }
    }
}

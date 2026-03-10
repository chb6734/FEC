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
    case drinks
    case dessert
    case snack   // legacy: kept for DB compatibility
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .korean: "Korean"
        case .chinese: "Chinese"
        case .japanese: "Japanese"
        case .western: "Western"
        case .drinks: "Drinks"
        case .dessert: "Dessert"
        case .snack: "Snack"
        case .other: "Other"
        }
    }

    var emoji: String {
        switch self {
        case .korean: "🇰🇷"
        case .chinese: "🇨🇳"
        case .japanese: "🇯🇵"
        case .western: "🍝"
        case .drinks: "🥤"
        case .dessert: "🍰"
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
        case .drinks: .cyan
        case .dessert: .brown
        case .snack: .yellow
        case .other: .purple
        }
    }

    /// Categories shown in onboarding (excludes legacy snack)
    static var onboardingCases: [FoodCategory] {
        [.korean, .chinese, .japanese, .western, .drinks, .dessert, .other]
    }
}

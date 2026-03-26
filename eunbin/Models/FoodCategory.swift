//
//  FoodCategory.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation
import SwiftUI

enum FoodCategory: String, Codable, CaseIterable, Identifiable {
    case korean = "한식"
    case chinese = "중식"
    case japanese = "일식"
    case italian = "이탈리안"
    case american = "아메리칸"
    case french = "프렌치"
    case southeastAsian = "동남아"
    case mexican = "멕시칸"
    case middleEastern = "중동"
    case salad = "샐러드"
    case noodle = "면류"
    case fastfood = "패스트푸드"
    case seafood = "해산물"
    case brunch = "브런치"
    case drinks = "음료"
    case dessert = "디저트"
    case snack = "분식"
    case other = "기타"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var emoji: String {
        switch self {
        case .korean: "🍚"
        case .chinese: "🥟"
        case .japanese: "🍣"
        case .italian: "🍝"
        case .american: "🍔"
        case .french: "🥐"
        case .southeastAsian: "🍜"
        case .mexican: "🌮"
        case .middleEastern: "🧆"
        case .salad: "🥗"
        case .noodle: "🍜"
        case .fastfood: "🍟"
        case .seafood: "🦐"
        case .brunch: "🥞"
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
        case .italian: .green
        case .american: .blue
        case .french: .purple
        case .southeastAsian: .yellow
        case .mexican: .mint
        case .middleEastern: .brown
        case .salad: .green.opacity(0.7)
        case .noodle: .brown
        case .fastfood: .red.opacity(0.8)
        case .seafood: .cyan
        case .brunch: .orange.opacity(0.7)
        case .drinks: .cyan
        case .dessert: .brown
        case .snack: .yellow
        case .other: .gray
        }
    }

    /// Categories shown in onboarding (excludes legacy snack)
    static var onboardingCases: [FoodCategory] {
        [.korean, .chinese, .japanese, .italian, .american, .french,
         .southeastAsian, .mexican, .middleEastern, .salad, .noodle,
         .fastfood, .seafood, .brunch, .drinks, .dessert, .other]
    }
}

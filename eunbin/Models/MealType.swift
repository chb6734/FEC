//
//  MealType.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast
    case lunch
    case dinner

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .breakfast: "아침"
        case .lunch: "점심"
        case .dinner: "저녁"
        }
    }

    var startHour: Int {
        switch self {
        case .breakfast: 6
        case .lunch: 11
        case .dinner: 17
        }
    }

    var endHour: Int {
        switch self {
        case .breakfast: 10
        case .lunch: 14
        case .dinner: 21
        }
    }

    var emoji: String {
        switch self {
        case .breakfast: "🌅"
        case .lunch: "☀️"
        case .dinner: "🌙"
        }
    }

    static func current(at date: Date = Date()) -> MealType {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<10: return .breakfast
        case 10..<11: return .lunch   // 아침~점심 사이 → 점심
        case 11..<14: return .lunch
        case 14..<17: return .dinner  // 점심~저녁 사이 → 저녁
        case 17..<21: return .dinner
        default: return .breakfast    // 21시~6시(야간) → 다음 아침
        }
    }
}

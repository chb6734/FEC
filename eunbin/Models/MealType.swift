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
    case lateNight
    case snack

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .breakfast: "아침"
        case .lunch: "점심"
        case .dinner: "저녁"
        case .lateNight: "야식"
        case .snack: "간식"
        }
    }

    var startHour: Int {
        switch self {
        case .breakfast: 6
        case .lunch: 11
        case .dinner: 17
        case .lateNight: 21
        case .snack: 0
        }
    }

    var endHour: Int {
        switch self {
        case .breakfast: 10
        case .lunch: 14
        case .dinner: 21
        case .lateNight: 6
        case .snack: 24
        }
    }

    var emoji: String {
        switch self {
        case .breakfast: "🌅"
        case .lunch: "🌞"
        case .dinner: "🌙"
        case .lateNight: "🌃"
        case .snack: "🍪"
        }
    }

    var systemImage: String {
        switch self {
        case .breakfast: "sunrise"
        case .lunch: "sun.max"
        case .dinner: "moon.stars"
        case .lateNight: "moon.zzz"
        case .snack: "fork.knife.circle"
        }
    }

    static func current(at date: Date = Date()) -> MealType {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<10: return .breakfast
        case 10..<14: return .lunch
        case 14..<17: return .dinner
        case 17..<21: return .dinner
        default: return .lateNight
        }
    }
}

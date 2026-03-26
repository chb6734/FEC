//
//  DietaryRestriction.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation

enum DietaryRestriction: String, Codable, CaseIterable, Identifiable {
    case none
    case vegetarian
    case vegan
    case glutenFree
    case lowCalorie
    case allergy

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: "없음"
        case .vegetarian: "Vegetarian"
        case .vegan: "Vegan"
        case .glutenFree: "Gluten Free"
        case .lowCalorie: "Low Calorie"
        case .allergy: "Allergy"
        }
    }
}

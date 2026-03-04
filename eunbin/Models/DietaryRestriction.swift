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
    case glutenFree
    case lowCalorie

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: "없음"
        case .vegetarian: "채식"
        case .glutenFree: "글루텐프리"
        case .lowCalorie: "저칼로리"
        }
    }
}

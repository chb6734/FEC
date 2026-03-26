//
//  BudgetRange.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation

enum BudgetRange: String, Codable, CaseIterable, Identifiable {
    case budget
    case medium
    case premium
    case noPreference

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .budget: "가성비 (1만원 이하)"
        case .medium: "적당히 (1~2만원)"
        case .premium: "넉넉히 (2만원 이상)"
        case .noPreference: "상관없음"
        }
    }
}

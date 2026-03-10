//
//  DesignSystem.swift
//  eunbin
//
//  Created by Maya Designer
//

import SwiftUI

enum AppDesign {
    // MARK: - Colors
    static let navy = Color(red: 0.10, green: 0.10, blue: 0.35)
    static let beige = Color(red: 0.96, green: 0.94, blue: 0.91)
    static let cardWhite = Color.white
    static let chipBorder = Color(red: 0.85, green: 0.83, blue: 0.80)
    static let subtitleGray = Color(red: 0.55, green: 0.53, blue: 0.50)
    static let disabledButton = Color(red: 0.65, green: 0.63, blue: 0.70)
    static let resetRed = Color(red: 0.85, green: 0.20, blue: 0.20)

    // MARK: - Fonts
    static let brandFont = Font.system(size: 32, weight: .bold, design: .serif)
    static let questionFont = Font.title2.bold()
    static let subtitleFont = Font.subheadline
    static let chipFont = Font.subheadline.weight(.medium)
    static let ctaFont = Font.headline

    // MARK: - Dimensions
    static let cornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 24
    static let horizontalPadding: CGFloat = 24
}

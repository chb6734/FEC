//
//  OnboardingViewModel.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation
import SwiftData
import Observation

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case mealPattern
    case restrictions
    case categories
    case dislikes
    case complete

    var title: String {
        switch self {
        case .welcome: return "환영합니다!"
        case .mealPattern: return "주로 식사하는 시간대는?"
        case .restrictions: return "식이 제한사항이 있나요?"
        case .categories: return "좋아하는 요리는?"
        case .dislikes: return "싫어하는 음식이 있나요?"
        case .complete: return "준비 완료!"
        }
    }

    var subtitle: String {
        switch self {
        case .welcome: return "맞춤 추천을 위해 몇 가지 질문을 드릴게요"
        case .mealPattern: return "여러 개 선택할 수 있어요"
        case .restrictions: return "해당되는 항목을 모두 선택하세요"
        case .categories: return "좋아하는 요리를 모두 선택하세요"
        case .dislikes: return "쉼표(,)로 구분해서 입력하세요 (선택)"
        case .complete: return "이제 맞춤 추천을 시작할게요"
        }
    }

    var isRequired: Bool {
        switch self {
        case .mealPattern, .restrictions, .categories: return true
        default: return false
        }
    }
}

@MainActor
@Observable
final class OnboardingViewModel {
    var currentStep: OnboardingStep = .welcome
    var selectedMealPatterns: Set<MealType> = []
    var selectedRestrictions: Set<DietaryRestriction> = []
    var selectedCategories: Set<FoodCategory> = []
    var dislikeText: String = ""

    var progress: Double {
        let total = Double(OnboardingStep.allCases.count - 1) // exclude welcome
        let current = Double(currentStep.rawValue)
        return min(current / total, 1.0)
    }

    var canProceed: Bool {
        switch currentStep {
        case .welcome, .dislikes, .complete:
            return true
        case .mealPattern:
            return !selectedMealPatterns.isEmpty
        case .restrictions:
            return !selectedRestrictions.isEmpty
        case .categories:
            return !selectedCategories.isEmpty
        }
    }

    var parsedDislikes: [String] {
        guard !dislikeText.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        return dislikeText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    func nextStep() {
        guard let nextIndex = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = nextIndex
    }

    func previousStep() {
        guard let prevIndex = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = prevIndex
    }

    func saveProfile(to modelContext: ModelContext) {
        let profile = UserProfile()
        profile.mealPattern = Array(selectedMealPatterns)
        profile.restrictions = Array(selectedRestrictions)
        profile.preferredCategories = Array(selectedCategories)
        profile.dislikes = parsedDislikes
        profile.hasCompletedOnboarding = true
        modelContext.insert(profile)
    }
}

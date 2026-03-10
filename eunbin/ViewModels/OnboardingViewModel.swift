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
    case mealPattern = 0
    case restrictions
    case categories

    var title: String {
        switch self {
        case .mealPattern: return "주로 언제 식사하시나요?"
        case .restrictions: return "식이 제한사항이 있나요?"
        case .categories: return "선호하는 요리 카테고리는?"
        }
    }

    var subtitle: String {
        switch self {
        case .mealPattern: return ""
        case .restrictions: return "해당하는 항목을 모두 선택해주세요."
        case .categories: return ""
        }
    }

    var isRequired: Bool { true }

    static var totalSteps: Int { allCases.count }
}

@MainActor
@Observable
final class OnboardingViewModel {
    var currentStep: OnboardingStep = .mealPattern
    var selectedMealPatterns: Set<MealType> = []
    var selectedRestrictions: Set<DietaryRestriction> = []
    var selectedCategories: Set<FoodCategory> = []
    var selectedBudget: BudgetRange?
    var dislikeText: String = ""

    var progress: Double {
        let total = Double(OnboardingStep.totalSteps)
        let current = Double(currentStep.rawValue + 1)
        return current / total
    }

    var canProceed: Bool {
        switch currentStep {
        case .mealPattern:
            return !selectedMealPatterns.isEmpty
        case .restrictions:
            return !selectedRestrictions.isEmpty
        case .categories:
            return !selectedCategories.isEmpty
        }
    }

    var isLastStep: Bool {
        currentStep == .categories
    }

    var isFirstStep: Bool {
        currentStep == .mealPattern
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
        profile.budget = selectedBudget
        profile.dislikes = parsedDislikes
        profile.hasCompletedOnboarding = true
        modelContext.insert(profile)
    }
}

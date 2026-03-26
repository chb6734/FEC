//
//  OnboardingViewModelTests.swift
//  eunbinTests
//
//  Created by Dohyun iOS Engineer
//

import Testing
import Foundation
@testable import eunbin

@MainActor
struct OnboardingViewModelTests {

    // MARK: - Initial State

    @Test func initialState() {
        let vm = OnboardingViewModel()
        #expect(vm.currentStep == .mealPattern)
        #expect(vm.selectedMealPatterns.isEmpty)
        #expect(vm.selectedRestrictions.isEmpty)
        #expect(vm.selectedCategories.isEmpty)
        #expect(vm.canProceed == false) // mealPattern requires selection
        #expect(vm.isFirstStep == true)
    }

    // MARK: - Step Navigation

    @Test func nextStepFromMealPattern() {
        let vm = OnboardingViewModel()
        vm.selectedMealPatterns.insert(.lunch)
        vm.nextStep()
        #expect(vm.currentStep == .restrictions)
    }

    @Test func cannotProceedWithoutSelection() {
        let vm = OnboardingViewModel()
        #expect(vm.canProceed == false) // no meal pattern selected
        vm.selectedMealPatterns.insert(.lunch)
        #expect(vm.canProceed == true)
    }

    @Test func fullFlowNavigation() {
        let vm = OnboardingViewModel()

        // Step 1: MealPattern → Restrictions
        vm.selectedMealPatterns.insert(.lunch)
        vm.nextStep()
        #expect(vm.currentStep == .restrictions)

        // Step 2: Restrictions → Categories
        vm.selectedRestrictions.insert(.none)
        vm.nextStep()
        #expect(vm.currentStep == .categories)

        // Step 3: Categories is last step
        vm.selectedCategories.insert(.korean)
        #expect(vm.isLastStep == true)
    }

    @Test func previousStep() {
        let vm = OnboardingViewModel()
        vm.currentStep = .restrictions
        vm.previousStep()
        #expect(vm.currentStep == .mealPattern)
    }

    @Test func previousStepFromFirstStaysAtFirst() {
        let vm = OnboardingViewModel()
        vm.previousStep()
        #expect(vm.currentStep == .mealPattern)
    }

    // MARK: - Progress

    @Test func progressCalculation() {
        let vm = OnboardingViewModel()
        #expect(vm.progress > 0.0) // mealPattern is step 1/3

        vm.currentStep = .restrictions
        #expect(vm.progress > 0.3)

        vm.currentStep = .categories
        #expect(vm.progress == 1.0)
    }

    // MARK: - Step Metadata

    @Test func stepTitles() {
        #expect(OnboardingStep.mealPattern.title == "주로 언제 식사하시나요?")
        #expect(OnboardingStep.restrictions.title == "식이 제한사항이 있나요?")
        #expect(OnboardingStep.categories.title == "선호하는 요리 카테고리는?")
    }

    @Test func allStepsAreRequired() {
        for step in OnboardingStep.allCases {
            #expect(step.isRequired == true)
        }
    }

    // MARK: - IsLastStep / IsFirstStep

    @Test func isLastStep() {
        let vm = OnboardingViewModel()
        #expect(vm.isLastStep == false)
        vm.currentStep = .categories
        #expect(vm.isLastStep == true)
    }

    @Test func isFirstStep() {
        let vm = OnboardingViewModel()
        #expect(vm.isFirstStep == true)
        vm.currentStep = .restrictions
        #expect(vm.isFirstStep == false)
    }

    // MARK: - Dislikes Parsing (kept for compatibility)

    @Test func dislikesParseFromText() {
        let vm = OnboardingViewModel()
        vm.dislikeText = "고수, 파, 민트"
        let parsed = vm.parsedDislikes
        #expect(parsed.count == 3)
        #expect(parsed.contains("고수"))
        #expect(parsed.contains("파"))
        #expect(parsed.contains("민트"))
    }

    @Test func emptyDislikesText() {
        let vm = OnboardingViewModel()
        vm.dislikeText = ""
        #expect(vm.parsedDislikes.isEmpty)
    }
}

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
        #expect(vm.currentStep == .welcome)
        #expect(vm.selectedMealPatterns.isEmpty)
        #expect(vm.selectedRestrictions.isEmpty)
        #expect(vm.selectedCategories.isEmpty)
        #expect(vm.dislikeText == "")
        #expect(vm.canProceed == true) // welcome can always proceed
    }

    // MARK: - Step Navigation

    @Test func nextStepFromWelcome() {
        let vm = OnboardingViewModel()
        vm.nextStep()
        #expect(vm.currentStep == .mealPattern)
    }

    @Test func nextStepRequiresSelection() {
        let vm = OnboardingViewModel()
        vm.currentStep = .mealPattern
        #expect(vm.canProceed == false) // no selection yet
        vm.selectedMealPatterns.insert(.lunch)
        #expect(vm.canProceed == true)
    }

    @Test func fullFlowNavigation() {
        let vm = OnboardingViewModel()

        // Welcome → MealPattern
        vm.nextStep()
        #expect(vm.currentStep == .mealPattern)

        // MealPattern → Restrictions
        vm.selectedMealPatterns.insert(.lunch)
        vm.nextStep()
        #expect(vm.currentStep == .restrictions)

        // Restrictions → Categories
        vm.selectedRestrictions.insert(.none)
        vm.nextStep()
        #expect(vm.currentStep == .categories)

        // Categories → Dislikes
        vm.selectedCategories.insert(.korean)
        vm.nextStep()
        #expect(vm.currentStep == .dislikes)

        // Dislikes → Complete
        vm.nextStep()
        #expect(vm.currentStep == .complete)
    }

    @Test func previousStep() {
        let vm = OnboardingViewModel()
        vm.currentStep = .restrictions
        vm.previousStep()
        #expect(vm.currentStep == .mealPattern)
    }

    @Test func previousStepFromWelcomeStaysAtWelcome() {
        let vm = OnboardingViewModel()
        vm.previousStep()
        #expect(vm.currentStep == .welcome)
    }

    // MARK: - Progress

    @Test func progressCalculation() {
        let vm = OnboardingViewModel()
        #expect(vm.progress == 0.0) // welcome

        vm.currentStep = .mealPattern
        #expect(vm.progress > 0.0)

        vm.currentStep = .complete
        #expect(vm.progress == 1.0)
    }

    // MARK: - Step Metadata

    @Test func stepTitles() {
        #expect(OnboardingStep.mealPattern.title == "주로 식사하는 시간대는?")
        #expect(OnboardingStep.restrictions.title == "식이 제한사항이 있나요?")
        #expect(OnboardingStep.categories.title == "좋아하는 요리는?")
        #expect(OnboardingStep.dislikes.title == "싫어하는 음식이 있나요?")
    }

    @Test func stepSubtitles() {
        #expect(!OnboardingStep.mealPattern.subtitle.isEmpty)
        #expect(!OnboardingStep.restrictions.subtitle.isEmpty)
    }

    // MARK: - Dislikes Parsing

    @Test func dislikesParseFromText() {
        let vm = OnboardingViewModel()
        vm.dislikeText = "고수, 파, 민트"
        let parsed = vm.parsedDislikes
        #expect(parsed.count == 3)
        #expect(parsed.contains("고수"))
        #expect(parsed.contains("파"))
        #expect(parsed.contains("민트"))
    }

    @Test func dislikesParseTrimsWhitespace() {
        let vm = OnboardingViewModel()
        vm.dislikeText = " 고수 , 파 "
        let parsed = vm.parsedDislikes
        #expect(parsed.contains("고수"))
        #expect(parsed.contains("파"))
    }

    @Test func emptyDislikesText() {
        let vm = OnboardingViewModel()
        vm.dislikeText = ""
        #expect(vm.parsedDislikes.isEmpty)
    }
}

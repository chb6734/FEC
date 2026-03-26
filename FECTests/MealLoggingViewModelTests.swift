//
//  MealLoggingViewModelTests.swift
//  eunbinTests
//
//  Created by Dohyun iOS Engineer
//

import Testing
import Foundation
@testable import eunbin

@MainActor
struct MealLoggingViewModelTests {

    // MARK: - Initialization

    @Test func initWithFood() {
        let food = FoodItem(id: "bibimbap", name: "비빔밥", category: .korean,
                           mealTypes: [.lunch], restrictions: [.none], tags: [], baseScore: 1.0)
        let vm = MealLoggingViewModel(food: food)
        #expect(vm.foodName == "비빔밥")
        #expect(vm.isFromRecommendation == true)
    }

    @Test func initWithoutFood() {
        let vm = MealLoggingViewModel()
        #expect(vm.foodName == "")
        #expect(vm.isFromRecommendation == false)
    }

    @Test func defaultMealTypeIsCurrentTime() {
        let vm = MealLoggingViewModel()
        #expect(vm.selectedMealType == MealType.current())
    }

    // MARK: - Validation

    @Test func canSaveWithValidInput() {
        let vm = MealLoggingViewModel()
        vm.foodName = "비빔밥"
        #expect(vm.canSave == true)
    }

    @Test func cannotSaveWithEmptyName() {
        let vm = MealLoggingViewModel()
        vm.foodName = ""
        #expect(vm.canSave == false)
    }

    @Test func cannotSaveWithWhitespaceOnlyName() {
        let vm = MealLoggingViewModel()
        vm.foodName = "   "
        #expect(vm.canSave == false)
    }

    // MARK: - Note

    @Test func noteIsOptional() {
        let vm = MealLoggingViewModel()
        vm.foodName = "파스타"
        vm.note = ""
        #expect(vm.canSave == true)
    }

    @Test func noteWithContent() {
        let vm = MealLoggingViewModel()
        vm.foodName = "파스타"
        vm.note = "맛있었음"
        #expect(vm.canSave == true)
    }

    // MARK: - Save State

    @Test func initialSaveState() {
        let vm = MealLoggingViewModel()
        #expect(vm.isSaved == false)
    }
}

//
//  RecommendationViewModelTests.swift
//  eunbinTests
//
//  스와이프 카드 관리 및 선택 추적 테스트
//

import Testing
import Foundation
@testable import eunbin

@MainActor
struct RecommendationViewModelTests {

    // MARK: - Helpers

    private func makeFoods(_ count: Int) -> [FoodItem] {
        (0..<count).map { i in
            FoodItem(
                id: "food_\(i)",
                name: "음식 \(i)",
                category: .korean,
                mealTypes: [.lunch],
                restrictions: [],
                tags: [],
                baseScore: 0.5
            )
        }
    }

    // MARK: - Card Advancement

    @Test func advanceCardIncrementsIndex() {
        let vm = RecommendationViewModel()
        vm.recommendations = makeFoods(3)
        #expect(vm.currentCardIndex == 0)
        vm.advanceCard()
        #expect(vm.currentCardIndex == 1)
        vm.advanceCard()
        #expect(vm.currentCardIndex == 2)
    }

    @Test func advanceCardGosPastLastCard() {
        let vm = RecommendationViewModel()
        vm.recommendations = makeFoods(3)
        vm.advanceCard()
        vm.advanceCard()
        vm.advanceCard()
        #expect(vm.currentCardIndex == 3)
    }

    @Test func advanceCardStopsAtCount() {
        let vm = RecommendationViewModel()
        vm.recommendations = makeFoods(2)
        vm.advanceCard()
        vm.advanceCard()
        vm.advanceCard() // should not exceed count
        #expect(vm.currentCardIndex == 2)
    }

    // MARK: - Current Card

    @Test func currentCardReturnsCorrectItem() {
        let vm = RecommendationViewModel()
        let foods = makeFoods(3)
        vm.recommendations = foods
        #expect(vm.currentCard?.id == "food_0")
        vm.advanceCard()
        #expect(vm.currentCard?.id == "food_1")
        vm.advanceCard()
        #expect(vm.currentCard?.id == "food_2")
    }

    @Test func currentCardReturnsNilWhenPastEnd() {
        let vm = RecommendationViewModel()
        vm.recommendations = makeFoods(1)
        vm.advanceCard()
        #expect(vm.currentCard == nil)
    }

    // MARK: - Has Reviewed All Cards

    @Test func hasReviewedAllCardsIsFalseInitially() {
        let vm = RecommendationViewModel()
        vm.recommendations = makeFoods(3)
        #expect(!vm.hasReviewedAllCards)
    }

    @Test func hasReviewedAllCardsIsTrueWhenAllAdvanced() {
        let vm = RecommendationViewModel()
        vm.recommendations = makeFoods(3)
        vm.advanceCard()
        vm.advanceCard()
        vm.advanceCard()
        #expect(vm.hasReviewedAllCards)
    }

    @Test func hasReviewedAllCardsIsFalseWhenEmpty() {
        let vm = RecommendationViewModel()
        #expect(!vm.hasReviewedAllCards)
    }

    @Test func hasReviewedAllCardsIsFalseInMiddle() {
        let vm = RecommendationViewModel()
        vm.recommendations = makeFoods(3)
        vm.advanceCard()
        #expect(!vm.hasReviewedAllCards)
    }

    // MARK: - Select Food

    @Test func selectFoodAddsToList() {
        let vm = RecommendationViewModel()
        let food = makeFoods(1)[0]
        vm.selectFood(food)
        #expect(vm.selectedFoods.count == 1)
        #expect(vm.selectedFoods.first?.id == "food_0")
    }

    @Test func selectFoodPreventsDuplicates() {
        let vm = RecommendationViewModel()
        let food = makeFoods(1)[0]
        vm.selectFood(food)
        vm.selectFood(food)
        #expect(vm.selectedFoods.count == 1)
    }

    @Test func selectMultipleFoods() {
        let vm = RecommendationViewModel()
        let foods = makeFoods(3)
        vm.selectFood(foods[0])
        vm.selectFood(foods[2])
        #expect(vm.selectedFoods.count == 2)
        #expect(vm.selectedFoods[0].id == "food_0")
        #expect(vm.selectedFoods[1].id == "food_2")
    }

    // MARK: - Full Swipe Flow

    @Test func fullFlowRightSwipeSelectsAndAdvances() {
        let vm = RecommendationViewModel()
        let foods = makeFoods(3)
        vm.recommendations = foods

        // Swipe right on all 3
        for food in foods {
            vm.selectFood(food)
            vm.advanceCard()
        }

        #expect(vm.hasReviewedAllCards)
        #expect(vm.selectedFoods.count == 3)
    }

    @Test func fullFlowMixedSwipes() {
        let vm = RecommendationViewModel()
        let foods = makeFoods(3)
        vm.recommendations = foods

        // Right swipe first card
        vm.selectFood(foods[0])
        vm.advanceCard()

        // Left swipe second card (just advance)
        vm.advanceCard()

        // Right swipe third card
        vm.selectFood(foods[2])
        vm.advanceCard()

        #expect(vm.hasReviewedAllCards)
        #expect(vm.selectedFoods.count == 2)
        #expect(vm.selectedFoods[0].id == "food_0")
        #expect(vm.selectedFoods[1].id == "food_2")
    }

    @Test func fullFlowAllLeftSwipes() {
        let vm = RecommendationViewModel()
        vm.recommendations = makeFoods(3)

        // Left swipe all
        vm.advanceCard()
        vm.advanceCard()
        vm.advanceCard()

        #expect(vm.hasReviewedAllCards)
        #expect(vm.selectedFoods.isEmpty)
    }
}

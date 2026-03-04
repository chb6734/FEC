//
//  ModelTests.swift
//  eunbinTests
//
//  Created by Dohyun iOS Engineer
//

import Testing
import Foundation
@testable import eunbin

// MARK: - FoodCategory Tests

struct FoodCategoryTests {
    @Test func allCasesExist() {
        let allCases = FoodCategory.allCases
        #expect(allCases.count == 6)
        #expect(allCases.contains(.korean))
        #expect(allCases.contains(.chinese))
        #expect(allCases.contains(.japanese))
        #expect(allCases.contains(.western))
        #expect(allCases.contains(.snack))
        #expect(allCases.contains(.other))
    }

    @Test func displayNames() {
        #expect(FoodCategory.korean.displayName == "한식")
        #expect(FoodCategory.chinese.displayName == "중식")
        #expect(FoodCategory.japanese.displayName == "일식")
        #expect(FoodCategory.western.displayName == "양식")
        #expect(FoodCategory.snack.displayName == "분식")
        #expect(FoodCategory.other.displayName == "기타")
    }
}

// MARK: - MealType Tests

struct MealTypeTests {
    @Test func allCasesExist() {
        let allCases = MealType.allCases
        #expect(allCases.count == 3)
        #expect(allCases.contains(.breakfast))
        #expect(allCases.contains(.lunch))
        #expect(allCases.contains(.dinner))
    }

    @Test func timeRanges() {
        #expect(MealType.breakfast.startHour == 6)
        #expect(MealType.breakfast.endHour == 10)
        #expect(MealType.lunch.startHour == 11)
        #expect(MealType.lunch.endHour == 14)
        #expect(MealType.dinner.startHour == 17)
        #expect(MealType.dinner.endHour == 21)
    }

    @Test func displayNames() {
        #expect(MealType.breakfast.displayName == "아침")
        #expect(MealType.lunch.displayName == "점심")
        #expect(MealType.dinner.displayName == "저녁")
    }

    @Test func currentMealTypeMapping() {
        let cal = Calendar.current
        func dateAt(hour: Int) -> Date {
            cal.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
        }
        // 야간 → 아침
        #expect(MealType.current(at: dateAt(hour: 2)) == .breakfast)
        #expect(MealType.current(at: dateAt(hour: 5)) == .breakfast)
        // 아침
        #expect(MealType.current(at: dateAt(hour: 7)) == .breakfast)
        // 아침~점심 사이 → 점심
        #expect(MealType.current(at: dateAt(hour: 10)) == .lunch)
        // 점심
        #expect(MealType.current(at: dateAt(hour: 12)) == .lunch)
        // 점심~저녁 사이 → 저녁
        #expect(MealType.current(at: dateAt(hour: 15)) == .dinner)
        // 저녁
        #expect(MealType.current(at: dateAt(hour: 19)) == .dinner)
        // 야간 → 아침
        #expect(MealType.current(at: dateAt(hour: 23)) == .breakfast)
    }
}

// MARK: - DietaryRestriction Tests

struct DietaryRestrictionTests {
    @Test func allCasesExist() {
        let allCases = DietaryRestriction.allCases
        #expect(allCases.contains(.none))
        #expect(allCases.contains(.vegetarian))
        #expect(allCases.contains(.glutenFree))
        #expect(allCases.contains(.lowCalorie))
    }

    @Test func displayNames() {
        #expect(DietaryRestriction.none.displayName == "없음")
        #expect(DietaryRestriction.vegetarian.displayName == "채식")
        #expect(DietaryRestriction.glutenFree.displayName == "글루텐프리")
        #expect(DietaryRestriction.lowCalorie.displayName == "저칼로리")
    }
}

// MARK: - FoodItem Tests

struct FoodItemTests {
    @Test func initializesCorrectly() {
        let food = FoodItem(
            id: "bibimbap",
            name: "비빔밥",
            category: .korean,
            mealTypes: [.lunch, .dinner],
            restrictions: [.none],
            tags: ["밥", "야채"],
            baseScore: 1.0
        )

        #expect(food.id == "bibimbap")
        #expect(food.name == "비빔밥")
        #expect(food.category == .korean)
        #expect(food.mealTypes.contains(.lunch))
        #expect(food.mealTypes.contains(.dinner))
        #expect(!food.mealTypes.contains(.breakfast))
        #expect(food.restrictions.contains(.none))
        #expect(food.tags.contains("밥"))
        #expect(food.baseScore == 1.0)
    }
}

// MARK: - UserProfile Tests

struct UserProfileTests {
    @Test func defaultProfileCreation() {
        let profile = UserProfile()
        #expect(profile.mealPattern.isEmpty)
        #expect(profile.restrictions.isEmpty)
        #expect(profile.preferredCategories.isEmpty)
        #expect(profile.dislikes.isEmpty)
        #expect(profile.hasCompletedOnboarding == false)
    }

    @Test func profileWithValues() {
        let profile = UserProfile()
        profile.mealPattern = [.lunch, .dinner]
        profile.restrictions = [.vegetarian]
        profile.preferredCategories = [.korean, .japanese]
        profile.dislikes = ["고수"]
        profile.hasCompletedOnboarding = true

        #expect(profile.mealPattern.count == 2)
        #expect(profile.restrictions.contains(.vegetarian))
        #expect(profile.preferredCategories.contains(.korean))
        #expect(profile.dislikes.contains("고수"))
        #expect(profile.hasCompletedOnboarding == true)
    }
}

// MARK: - MealLog Tests

struct MealLogTests {
    @Test func initializesCorrectly() {
        let now = Date()
        let log = MealLog(foodName: "김치찌개", mealType: .lunch, timestamp: now)

        #expect(log.foodName == "김치찌개")
        #expect(log.mealType == .lunch)
        #expect(log.timestamp == now)
        #expect(log.note == nil)
    }

    @Test func initializesWithNote() {
        let log = MealLog(foodName: "파스타", mealType: .dinner, timestamp: Date(), note: "맛있었음")
        #expect(log.note == "맛있었음")
    }
}

// MARK: - FoodDatabase Tests

struct FoodDatabaseTests {
    @Test func loadsAllFoods() {
        let foods = FoodDatabase.allFoods
        #expect(foods.count >= 200)
    }

    @Test func hasAllCategories() {
        let foods = FoodDatabase.allFoods
        let categories = Set(foods.map { $0.category })
        #expect(categories.contains(.korean))
        #expect(categories.contains(.chinese))
        #expect(categories.contains(.japanese))
        #expect(categories.contains(.western))
        #expect(categories.contains(.snack))
    }

    @Test func hasAllMealTypes() {
        let foods = FoodDatabase.allFoods
        let breakfastFoods = foods.filter { $0.mealTypes.contains(.breakfast) }
        let lunchFoods = foods.filter { $0.mealTypes.contains(.lunch) }
        let dinnerFoods = foods.filter { $0.mealTypes.contains(.dinner) }
        #expect(!breakfastFoods.isEmpty)
        #expect(!lunchFoods.isEmpty)
        #expect(!dinnerFoods.isEmpty)
    }

    @Test func foodsByCategory() {
        let koreanFoods = FoodDatabase.foods(for: .korean)
        #expect(!koreanFoods.isEmpty)
        for food in koreanFoods {
            #expect(food.category == .korean)
        }
    }

    @Test func foodsByMealType() {
        let breakfastFoods = FoodDatabase.foods(for: .breakfast)
        #expect(!breakfastFoods.isEmpty)
        for food in breakfastFoods {
            #expect(food.mealTypes.contains(.breakfast))
        }
    }

    @Test func uniqueIds() {
        let foods = FoodDatabase.allFoods
        let ids = foods.map { $0.id }
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
    }
}

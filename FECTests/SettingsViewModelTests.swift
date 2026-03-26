//
//  SettingsViewModelTests.swift
//  eunbinTests
//
//  Created by Dohyun iOS Engineer
//

import Testing
import Foundation
@testable import eunbin

@MainActor
struct SettingsViewModelTests {

    // MARK: - Load from Profile

    @Test func loadsFromProfile() {
        let profile = UserProfile()
        profile.mealPattern = [.lunch, .dinner]
        profile.restrictions = [.vegetarian]
        profile.preferredCategories = [.korean, .japanese]
        profile.dislikes = ["고수", "파"]

        let vm = SettingsViewModel()
        vm.loadFrom(profile: profile)

        #expect(vm.selectedMealPatterns.contains(.lunch))
        #expect(vm.selectedMealPatterns.contains(.dinner))
        #expect(vm.selectedRestrictions.contains(.vegetarian))
        #expect(vm.selectedCategories.contains(.korean))
        #expect(vm.selectedCategories.contains(.japanese))
        #expect(vm.dislikeText == "고수, 파")
    }

    @Test func loadsEmptyProfile() {
        let profile = UserProfile()
        let vm = SettingsViewModel()
        vm.loadFrom(profile: profile)

        #expect(vm.selectedMealPatterns.isEmpty)
        #expect(vm.selectedRestrictions.isEmpty)
        #expect(vm.selectedCategories.isEmpty)
        #expect(vm.dislikeText == "")
    }

    // MARK: - Validation

    @Test func canSaveWithAtLeastOneMealPattern() {
        let vm = SettingsViewModel()
        vm.selectedMealPatterns = [.lunch]
        vm.selectedRestrictions = [.none]
        vm.selectedCategories = [.korean]
        #expect(vm.canSave == true)
    }

    @Test func cannotSaveWithEmptyMealPattern() {
        let vm = SettingsViewModel()
        vm.selectedMealPatterns = []
        vm.selectedRestrictions = [.none]
        vm.selectedCategories = [.korean]
        #expect(vm.canSave == false)
    }

    @Test func cannotSaveWithEmptyRestrictions() {
        let vm = SettingsViewModel()
        vm.selectedMealPatterns = [.lunch]
        vm.selectedRestrictions = []
        vm.selectedCategories = [.korean]
        #expect(vm.canSave == false)
    }

    @Test func cannotSaveWithEmptyCategories() {
        let vm = SettingsViewModel()
        vm.selectedMealPatterns = [.lunch]
        vm.selectedRestrictions = [.none]
        vm.selectedCategories = []
        #expect(vm.canSave == false)
    }

    // MARK: - Dislikes Parsing

    @Test func parseDislikes() {
        let vm = SettingsViewModel()
        vm.dislikeText = "고수, 파, 민트"
        #expect(vm.parsedDislikes == ["고수", "파", "민트"])
    }

    @Test func emptyDislikes() {
        let vm = SettingsViewModel()
        vm.dislikeText = ""
        #expect(vm.parsedDislikes.isEmpty)
    }

    // MARK: - Has Changes

    @Test func detectsChanges() {
        let profile = UserProfile()
        profile.mealPattern = [.lunch]
        profile.restrictions = [.none]
        profile.preferredCategories = [.korean]
        profile.dislikes = []

        let vm = SettingsViewModel()
        vm.loadFrom(profile: profile)
        #expect(vm.hasChanges(from: profile) == false)

        vm.selectedCategories.insert(.japanese)
        #expect(vm.hasChanges(from: profile) == true)
    }
}

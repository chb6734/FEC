//
//  FeedbackTests.swift
//  eunbinTests
//
//  Created by Dohyun iOS Engineer
//

import Testing
import Foundation
@testable import eunbin

struct FeedbackRecordTests {
    @Test func initializesCorrectly() {
        let feedback = FeedbackRecord(foodId: "bibimbap", isLiked: true)
        #expect(feedback.foodId == "bibimbap")
        #expect(feedback.isLiked == true)
    }

    @Test func dislikeRecord() {
        let feedback = FeedbackRecord(foodId: "jajangmyeon", isLiked: false)
        #expect(feedback.isLiked == false)
    }
}

@MainActor
struct FeedbackViewModelTests {
    @Test func initialStateHasNoFeedback() {
        let vm = FeedbackViewModel()
        #expect(vm.getFeedback(for: "bibimbap") == nil)
    }

    @Test func toggleLike() {
        let vm = FeedbackViewModel()
        vm.toggleFeedback(foodId: "bibimbap", isLiked: true, feedbacks: [])
        #expect(vm.pendingFeedbacks["bibimbap"] == true)
    }

    @Test func toggleDislike() {
        let vm = FeedbackViewModel()
        vm.toggleFeedback(foodId: "bibimbap", isLiked: false, feedbacks: [])
        #expect(vm.pendingFeedbacks["bibimbap"] == false)
    }

    @Test func toggleSameRemovesFeedback() {
        let vm = FeedbackViewModel()
        vm.toggleFeedback(foodId: "bibimbap", isLiked: true, feedbacks: [])
        vm.toggleFeedback(foodId: "bibimbap", isLiked: true, feedbacks: [])
        #expect(vm.pendingFeedbacks["bibimbap"] == nil)
    }

    @Test func switchFromLikeToDislike() {
        let vm = FeedbackViewModel()
        vm.toggleFeedback(foodId: "bibimbap", isLiked: true, feedbacks: [])
        vm.toggleFeedback(foodId: "bibimbap", isLiked: false, feedbacks: [])
        #expect(vm.pendingFeedbacks["bibimbap"] == false)
    }

    @Test func getFeedbackFromExistingRecords() {
        let vm = FeedbackViewModel()
        let existingFeedback = FeedbackRecord(foodId: "bibimbap", isLiked: true)
        let result = vm.getFeedback(for: "bibimbap", in: [existingFeedback])
        #expect(result == true)
    }

    @Test func pendingOverridesExisting() {
        let vm = FeedbackViewModel()
        let existingFeedback = FeedbackRecord(foodId: "bibimbap", isLiked: true)
        vm.toggleFeedback(foodId: "bibimbap", isLiked: false, feedbacks: [existingFeedback])
        let result = vm.getFeedback(for: "bibimbap", in: [existingFeedback])
        #expect(result == false)
    }
}

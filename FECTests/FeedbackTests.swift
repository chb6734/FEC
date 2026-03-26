//
//  FeedbackTests.swift
//  eunbinTests
//
//  Created by Dohyun iOS Engineer
//

import Testing
import Foundation
@testable import eunbin

// MARK: - FeedbackRecord 모델 테스트
/// FeedbackRecord 구조체의 초기화 및 기본 동작을 검증하는 테스트
struct FeedbackRecordTests {
    
    /// FeedbackRecord가 올바르게 초기화되는지 테스트
    /// - 음식 ID와 좋아요 상태가 정확히 저장되는지 확인
    @Test func initializesCorrectly() {
        let feedback = FeedbackRecord(foodId: "bibimbap", isLiked: true)
        #expect(feedback.foodId == "bibimbap")
        #expect(feedback.isLiked == true)
    }

    /// 싫어요 피드백이 정상적으로 기록되는지 테스트
    /// - isLiked가 false로 설정되는지 확인
    @Test func dislikeRecord() {
        let feedback = FeedbackRecord(foodId: "jajangmyeon", isLiked: false)
        #expect(feedback.isLiked == false)
    }
}

// MARK: - FeedbackViewModel 비즈니스 로직 테스트
/// FeedbackViewModel의 피드백 관리 로직을 검증하는 테스트
@MainActor
struct FeedbackViewModelTests {
    
    /// ViewModel의 초기 상태가 비어있는지 테스트
    /// - 피드백이 없는 음식에 대해 nil을 반환하는지 확인
    @Test func initialStateHasNoFeedback() {
        let vm = FeedbackViewModel()
        #expect(vm.getFeedback(for: "bibimbap") == nil)
    }

    /// 좋아요 토글 기능 테스트
    /// - 음식에 대한 좋아요가 pendingFeedbacks에 저장되는지 확인
    @Test func toggleLike() {
        let vm = FeedbackViewModel()
        vm.toggleFeedback(foodId: "bibimbap", isLiked: true, feedbacks: [])
        #expect(vm.pendingFeedbacks["bibimbap"] == true)
    }

    /// 싫어요 토글 기능 테스트
    /// - 음식에 대한 싫어요가 pendingFeedbacks에 저장되는지 확인
    @Test func toggleDislike() {
        let vm = FeedbackViewModel()
        vm.toggleFeedback(foodId: "bibimbap", isLiked: false, feedbacks: [])
        #expect(vm.pendingFeedbacks["bibimbap"] == false)
    }

    /// 동일한 피드백을 두 번 토글하면 취소되는지 테스트
    /// - 같은 버튼을 두 번 누르면 피드백이 제거되는지 확인 (토글 취소 동작)
    @Test func toggleSameRemovesFeedback() {
        let vm = FeedbackViewModel()
        vm.toggleFeedback(foodId: "bibimbap", isLiked: true, feedbacks: [])
        vm.toggleFeedback(foodId: "bibimbap", isLiked: true, feedbacks: [])
        #expect(vm.pendingFeedbacks["bibimbap"] == nil)
    }

    /// 좋아요에서 싫어요로 전환하는 테스트
    /// - 이전 피드백이 새로운 피드백으로 덮어씌워지는지 확인
    @Test func switchFromLikeToDislike() {
        let vm = FeedbackViewModel()
        vm.toggleFeedback(foodId: "bibimbap", isLiked: true, feedbacks: [])
        vm.toggleFeedback(foodId: "bibimbap", isLiked: false, feedbacks: [])
        #expect(vm.pendingFeedbacks["bibimbap"] == false)
    }

    /// 기존 피드백 레코드에서 데이터를 가져오는 테스트
    /// - 저장된 피드백 배열에서 특정 음식의 피드백을 조회할 수 있는지 확인
    @Test func getFeedbackFromExistingRecords() {
        let vm = FeedbackViewModel()
        let existingFeedback = FeedbackRecord(foodId: "bibimbap", isLiked: true)
        let result = vm.getFeedback(for: "bibimbap", in: [existingFeedback])
        #expect(result == true)
    }

    /// 대기 중인 피드백이 기존 피드백보다 우선되는지 테스트
    /// - pendingFeedbacks가 저장된 피드백을 오버라이드하는지 확인
    /// - 사용자가 새로 입력한 피드백이 아직 저장되지 않은 경우의 동작 검증
    @Test func pendingOverridesExisting() {
        let vm = FeedbackViewModel()
        let existingFeedback = FeedbackRecord(foodId: "bibimbap", isLiked: true)
        vm.toggleFeedback(foodId: "bibimbap", isLiked: false, feedbacks: [existingFeedback])
        let result = vm.getFeedback(for: "bibimbap", in: [existingFeedback])
        #expect(result == false)
    }
}

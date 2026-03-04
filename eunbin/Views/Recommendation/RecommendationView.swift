//
//  RecommendationView.swift
//  eunbin
//
//  Created by Maya Designer & Dohyun iOS Engineer
//

import SwiftUI
import SwiftData

struct RecommendationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \MealLog.timestamp, order: .reverse) private var logs: [MealLog]
    @Query private var feedbacks: [FeedbackRecord]
    @State private var viewModel = RecommendationViewModel()
    @State private var feedbackVM = FeedbackViewModel()
    @State private var selectedFood: FoodItem?
    @State private var showManualLogging = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    mealTimeHeader

                    if viewModel.recommendations.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.recommendations) { food in
                                FoodCard(
                                    food: food,
                                    feedbackState: feedbackVM.getFeedback(for: food.id, in: feedbacks),
                                    onTap: { selectedFood = food },
                                    onLike: {
                                        feedbackVM.toggleFeedback(foodId: food.id, isLiked: true, feedbacks: feedbacks)
                                        feedbackVM.savePendingFeedbacks(to: modelContext, existing: feedbacks)
                                    },
                                    onDislike: {
                                        feedbackVM.toggleFeedback(foodId: food.id, isLiked: false, feedbacks: feedbacks)
                                        feedbackVM.savePendingFeedbacks(to: modelContext, existing: feedbacks)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    Button {
                        showManualLogging = true
                    } label: {
                        Label("직접 입력하기", systemImage: "square.and.pencil")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.orange)
                    }
                    .padding(.top, 8)
                }
                .padding(.top)
            }
            .navigationTitle("오늘 뭐 먹지?")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.refresh(profile: profile, logs: logs, feedbacks: feedbacks)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        Text("설정 (준비 중)")
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(item: $selectedFood) { food in
                MealLoggingView(food: food) {
                    selectedFood = nil
                    viewModel.refresh(profile: profile, logs: logs, feedbacks: feedbacks)
                }
            }
            .sheet(isPresented: $showManualLogging) {
                MealLoggingView {
                    showManualLogging = false
                    viewModel.refresh(profile: profile, logs: logs, feedbacks: feedbacks)
                }
            }
            .onAppear {
                viewModel.loadRecommendations(profile: profile, logs: logs, feedbacks: feedbacks)
            }
        }
    }

    private var mealTimeHeader: some View {
        VStack(spacing: 4) {
            Text("\(viewModel.currentMealType.emoji) \(viewModel.currentMealType.displayName) 추천")
                .font(.title2.bold())
            Text("지금 시간대에 맞는 메뉴를 골라봤어요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("🤔")
                .font(.system(size: 60))
            Text("추천할 메뉴가 없어요")
                .font(.headline)
            Text("설정에서 선호도를 조정해보세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 60)
    }
}

// MARK: - Food Card

struct FoodCard: View {
    let food: FoodItem
    let feedbackState: Bool?
    let onTap: () -> Void
    let onLike: () -> Void
    let onDislike: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Main card content (tappable)
            Button(action: onTap) {
                HStack(spacing: 16) {
                    Text(food.category.emoji)
                        .font(.system(size: 36))
                        .frame(width: 56, height: 56)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(food.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        HStack(spacing: 6) {
                            Text(food.category.displayName)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.15))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                            ForEach(food.tags.prefix(2), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Spacer()
                }
            }
            .buttonStyle(.plain)

            // Feedback buttons
            VStack(spacing: 8) {
                Button(action: onLike) {
                    Image(systemName: feedbackState == true ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundStyle(feedbackState == true ? .red : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("맘에 들어요")

                Button(action: onDislike) {
                    Image(systemName: feedbackState == false ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        .font(.system(size: 18))
                        .foregroundStyle(feedbackState == false ? .blue : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("별로예요")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(food.name), \(food.category.displayName)")
    }
}

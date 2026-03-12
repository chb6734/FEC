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
            VStack(spacing: 0) {
                // Top bar
                topBar
                    .padding(.horizontal, AppDesign.horizontalPadding)
                    .padding(.top, 8)

                // Meal time badge
                mealTimeBadge
                    .padding(.top, 12)

                if viewModel.hasReviewedAllCards {
                    resultsList
                } else if viewModel.recommendations.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    Spacer()
                    cardStack
                    Spacer()
                }

                // Bottom action buttons
                if !viewModel.recommendations.isEmpty && !viewModel.hasReviewedAllCards {
                    actionButtons
                        .padding(.bottom, 20)
                }
            }
            .background(AppDesign.beige.ignoresSafeArea())
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
                viewModel.configure(modelContext: modelContext)
                viewModel.loadRecommendations(profile: profile, logs: logs, feedbacks: feedbacks)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Text("Plouf")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(AppDesign.navy)

            Spacer()

            if let profile {
                NavigationLink {
                    SettingsView(profile: profile)
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundStyle(AppDesign.navy)
                }
            }
        }
    }

    // MARK: - Meal Time Badge

    private var mealTimeBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock")
                .font(.caption)
            Text("\(viewModel.currentMealType.displayName) Recommendation")
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(AppDesign.navy)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppDesign.cardWhite)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        ZStack {
            ForEach(Array(viewModel.recommendations.enumerated().reversed()), id: \.element.id) { index, food in
                SwipeableCard(
                    food: food,
                    isTopCard: index == viewModel.currentCardIndex,
                    cardOffset: index - viewModel.currentCardIndex,
                    onSwipeLeft: {
                        feedbackVM.toggleFeedback(foodId: food.id, isLiked: false, feedbacks: feedbacks)
                        feedbackVM.savePendingFeedbacks(to: modelContext, existing: feedbacks)
                        viewModel.advanceCard()
                    },
                    onSwipeRight: {
                        feedbackVM.toggleFeedback(foodId: food.id, isLiked: true, feedbacks: feedbacks)
                        feedbackVM.savePendingFeedbacks(to: modelContext, existing: feedbacks)
                        viewModel.selectFood(food)
                        viewModel.advanceCard()
                    },
                    onTap: {
                        selectedFood = food
                    }
                )
            }
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 32) {
            // Reject button
            Button {
                if let food = viewModel.currentCard {
                    feedbackVM.toggleFeedback(foodId: food.id, isLiked: false, feedbacks: feedbacks)
                    feedbackVM.savePendingFeedbacks(to: modelContext, existing: feedbacks)
                    viewModel.advanceCard()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppDesign.navy)
                    .frame(width: 56, height: 56)
                    .background(AppDesign.cardWhite)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
            }

            // Like button
            Button {
                if let food = viewModel.currentCard {
                    feedbackVM.toggleFeedback(foodId: food.id, isLiked: true, feedbacks: feedbacks)
                    feedbackVM.savePendingFeedbacks(to: modelContext, existing: feedbacks)
                    viewModel.selectFood(food)
                    viewModel.advanceCard()
                }
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(AppDesign.navy)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
            }
        }
    }

    // MARK: - Results List

    private var resultsList: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("오늘의 추천 결과")
                    .font(.title2.bold())
                    .foregroundStyle(AppDesign.navy)
                    .padding(.top, 20)

                if viewModel.selectedFoods.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "hand.thumbsdown")
                            .font(.system(size: 40))
                            .foregroundStyle(AppDesign.subtitleGray)
                        Text("선택한 메뉴가 없어요")
                            .font(.headline)
                            .foregroundStyle(AppDesign.subtitleGray)
                    }
                    .padding(.top, 40)
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.selectedFoods) { food in
                            Button {
                                selectedFood = food
                            } label: {
                                HStack(spacing: 16) {
                                    Text(food.category.emoji)
                                        .font(.system(size: 32))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(food.name)
                                            .font(.headline)
                                            .foregroundStyle(AppDesign.navy)
                                        Text(food.category.displayName)
                                            .font(.caption)
                                            .foregroundStyle(AppDesign.subtitleGray)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(AppDesign.subtitleGray)
                                }
                                .padding(16)
                                .background(AppDesign.cardWhite)
                                .clipShape(RoundedRectangle(cornerRadius: AppDesign.cornerRadius))
                                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                            }
                        }
                    }
                }

                Button {
                    viewModel.refresh(profile: profile, logs: logs, feedbacks: feedbacks)
                } label: {
                    Text("다시 추천받기")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppDesign.navy)
                        .clipShape(RoundedRectangle(cornerRadius: AppDesign.cornerRadius))
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, AppDesign.horizontalPadding)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife")
                .font(.system(size: 48))
                .foregroundStyle(AppDesign.subtitleGray)
            Text("추천할 메뉴가 없어요")
                .font(.headline)
                .foregroundStyle(AppDesign.navy)
            Text("설정에서 선호도를 조정해보세요")
                .font(.subheadline)
                .foregroundStyle(AppDesign.subtitleGray)

            Button {
                viewModel.refresh(profile: profile, logs: logs, feedbacks: feedbacks)
            } label: {
                Text("새로고침")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppDesign.navy)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Swipeable Card

struct SwipeableCard: View {
    let food: FoodItem
    let isTopCard: Bool
    let cardOffset: Int
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    let onTap: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    private var rotation: Double {
        Double(dragOffset.width) / 20.0
    }

    var body: some View {
        if cardOffset >= 0 && cardOffset < 3 {
            cardContent
                .scaleEffect(isTopCard ? 1.0 : 1.0 - CGFloat(cardOffset) * 0.05)
                .offset(y: isTopCard ? 0 : CGFloat(cardOffset) * 10)
                .offset(x: isTopCard ? dragOffset.width : 0,
                        y: isTopCard ? dragOffset.height : 0)
                .rotationEffect(.degrees(isTopCard ? rotation : 0))
                .gesture(isTopCard ? dragGesture : nil)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
                .zIndex(Double(10 - cardOffset))
                .allowsHitTesting(isTopCard)
        }
    }

    private var cardContent: some View {
        VStack(spacing: 0) {
            // Top area with branding + image
            ZStack {
                VStack(spacing: 12) {
                    Text("Plouf")
                        .font(.system(size: 28, weight: .bold, design: .serif))

                    // Food image placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 140, height: 120)
                        .overlay(
                            Text(food.category.emoji)
                                .font(.system(size: 56))
                        )

                    Spacer().frame(height: 8)

                    Text("[ \(food.name) ]")
                        .font(.title3.bold())
                }
                .padding(.vertical, 32)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(AppDesign.navy)
        }
        .background(AppDesign.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: AppDesign.cardCornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: AppDesign.cardCornerRadius))
        .onTapGesture(perform: onTap)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
                isDragging = true
            }
            .onEnded { value in
                isDragging = false
                let threshold: CGFloat = 100
                if value.translation.width > threshold {
                    withAnimation(.easeOut(duration: 0.3)) {
                        dragOffset = CGSize(width: 500, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dragOffset = .zero
                        onSwipeRight()
                    }
                } else if value.translation.width < -threshold {
                    withAnimation(.easeOut(duration: 0.3)) {
                        dragOffset = CGSize(width: -500, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dragOffset = .zero
                        onSwipeLeft()
                    }
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = .zero
                    }
                }
            }
    }
}

// MARK: - Preview

#Preview("추천 화면") {
    NavigationStack {
        RecommendationView()
            .modelContainer(for: [UserProfile.self, MealLog.self, FeedbackRecord.self])
    }
}

#Preview("추천 카드만") {
    SwipeableCard(
        food: FoodItem(
            id: "bibimbap",
            name: "비빔밥",
            category: .korean,
            mealTypes: [.lunch, .dinner],
            restrictions: [],
            tags: ["건강", "야채"],
            baseScore: 0.8
        ),
        isTopCard: true,
        cardOffset: 0,
        onSwipeLeft: { print("Swiped left") },
        onSwipeRight: { print("Swiped right") },
        onTap: { print("Tapped") }
    )
    .padding()
}

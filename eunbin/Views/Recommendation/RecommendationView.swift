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
                mealTimeHeader

                if viewModel.recommendations.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    Spacer()
                    cardStack
                    Spacer()
                    feedbackButtons
                        .padding(.bottom, 8)
                }

                Button {
                    showManualLogging = true
                } label: {
                    Label("직접 입력하기", systemImage: "square.and.pencil")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.orange)
                }
                .padding(.bottom, 24)
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
                    if let profile {
                        NavigationLink {
                            SettingsView(profile: profile)
                        } label: {
                            Image(systemName: "gearshape")
                        }
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
                viewModel.configure(modelContext: modelContext)
                viewModel.loadRecommendations(profile: profile, logs: logs, feedbacks: feedbacks)
            }
        }
    }

    // MARK: - Meal Time Header

    private var mealTimeHeader: some View {
        VStack(spacing: 4) {
            Text("\(viewModel.currentMealType.emoji) \(viewModel.currentMealType.displayName) 추천")
                .font(.title2.bold())
            Text("스와이프하여 메뉴를 탐색해보세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    // MARK: - Card Stack (Tinder-style)

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
                        selectedFood = food
                        viewModel.advanceCard()
                    },
                    onTap: {
                        selectedFood = food
                    }
                )
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Feedback Buttons

    private var feedbackButtons: some View {
        HStack(spacing: 40) {
            if let currentFood = viewModel.currentCard {
                Button {
                    feedbackVM.toggleFeedback(foodId: currentFood.id, isLiked: false, feedbacks: feedbacks)
                    feedbackVM.savePendingFeedbacks(to: modelContext, existing: feedbacks)
                } label: {
                    let isDisliked = feedbackVM.getFeedback(for: currentFood.id, in: feedbacks) == false
                    Image(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        .font(.system(size: 24))
                        .foregroundStyle(isDisliked ? .blue : .secondary)
                        .frame(width: 56, height: 56)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .accessibilityLabel("별로예요")

                Button {
                    feedbackVM.toggleFeedback(foodId: currentFood.id, isLiked: true, feedbacks: feedbacks)
                    feedbackVM.savePendingFeedbacks(to: modelContext, existing: feedbacks)
                } label: {
                    let isLiked = feedbackVM.getFeedback(for: currentFood.id, in: feedbacks) == true
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 24))
                        .foregroundStyle(isLiked ? .red : .secondary)
                        .frame(width: 56, height: 56)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .accessibilityLabel("맘에 들어요")
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Empty State

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

    private var swipeDirection: SwipeDirection? {
        if dragOffset.width > 100 { return .right }
        if dragOffset.width < -100 { return .left }
        return nil
    }

    var body: some View {
        if cardOffset >= 0 && cardOffset < 3 {
            cardContent
                .scaleEffect(isTopCard ? 1.0 : 1.0 - CGFloat(cardOffset) * 0.05)
                .offset(y: isTopCard ? 0 : CGFloat(cardOffset) * 12)
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
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Food emoji/image area
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(food.category.themeColor.opacity(0.1))
                    Text(food.category.emoji)
                        .font(.system(size: 72))
                }
                .frame(height: 200)

                // Food info
                VStack(spacing: 8) {
                    Text(food.name)
                        .font(.title.bold())
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        Text(food.category.displayName)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(food.category.themeColor.opacity(0.15))
                            .foregroundStyle(food.category.themeColor)
                            .clipShape(Capsule())

                        ForEach(food.tags.prefix(2), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Swipe hint overlay
                if isTopCard && isDragging {
                    swipeHint
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(food.category.themeColor.opacity(0.6), lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var swipeHint: some View {
        if let direction = swipeDirection {
            Text(direction == .right ? "선택!" : "패스")
                .font(.title3.bold())
                .foregroundStyle(direction == .right ? .green : .red)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(direction == .right ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                )
                .transition(.opacity)
        }
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

private enum SwipeDirection {
    case left, right
}

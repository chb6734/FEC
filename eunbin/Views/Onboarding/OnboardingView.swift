//
//  OnboardingView.swift
//  eunbin
//
//  Created by Maya Designer & Dohyun iOS Engineer
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            if viewModel.currentStep != .welcome && viewModel.currentStep != .complete {
                ProgressView(value: viewModel.progress)
                    .tint(.orange)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }

            Spacer()

            // Content
            Group {
                switch viewModel.currentStep {
                case .welcome:
                    welcomeContent
                case .mealPattern:
                    mealPatternContent
                case .restrictions:
                    restrictionsContent
                case .categories:
                    categoriesContent
                case .budget:
                    budgetContent
                case .dislikes:
                    dislikesContent
                case .complete:
                    completeContent
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // Navigation Buttons
            navigationButtons
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
    }

    // MARK: - Welcome

    private var welcomeContent: some View {
        VStack(spacing: 16) {
            Text("🍽️")
                .font(.system(size: 80))
            Text("식사 추천")
                .font(.largeTitle.bold())
            Text("무엇을 먹을지 고민될 때,\n나에게 맞는 음식을 추천해드려요")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Meal Pattern

    private var mealPatternContent: some View {
        VStack(spacing: 24) {
            stepHeader(viewModel.currentStep)
            FlowLayout(spacing: 12) {
                ForEach(MealType.allCases) { type in
                    ChipButton(
                        title: "\(type.emoji) \(type.displayName)",
                        isSelected: viewModel.selectedMealPatterns.contains(type)
                    ) {
                        toggleSelection(&viewModel.selectedMealPatterns, type)
                    }
                }
            }
        }
    }

    // MARK: - Restrictions

    private var restrictionsContent: some View {
        VStack(spacing: 24) {
            stepHeader(viewModel.currentStep)
            FlowLayout(spacing: 12) {
                ForEach(DietaryRestriction.allCases) { restriction in
                    ChipButton(
                        title: restriction.displayName,
                        isSelected: viewModel.selectedRestrictions.contains(restriction)
                    ) {
                        toggleSelection(&viewModel.selectedRestrictions, restriction)
                    }
                }
            }
        }
    }

    // MARK: - Categories

    private var categoriesContent: some View {
        VStack(spacing: 24) {
            stepHeader(viewModel.currentStep)
            FlowLayout(spacing: 12) {
                ForEach(FoodCategory.allCases) { category in
                    ChipButton(
                        title: "\(category.emoji) \(category.displayName)",
                        isSelected: viewModel.selectedCategories.contains(category)
                    ) {
                        toggleSelection(&viewModel.selectedCategories, category)
                    }
                }
            }
        }
    }

    // MARK: - Budget

    private var budgetContent: some View {
        VStack(spacing: 24) {
            stepHeader(viewModel.currentStep)
            FlowLayout(spacing: 12) {
                ForEach(BudgetRange.allCases) { budget in
                    ChipButton(
                        title: budget.displayName,
                        isSelected: viewModel.selectedBudget == budget
                    ) {
                        if viewModel.selectedBudget == budget {
                            viewModel.selectedBudget = nil
                        } else {
                            viewModel.selectedBudget = budget
                        }
                    }
                }
            }
        }
    }

    // MARK: - Dislikes

    private var dislikesContent: some View {
        VStack(spacing: 24) {
            stepHeader(viewModel.currentStep)
            TextField("예: 고수, 파, 민트", text: $viewModel.dislikeText)
                .textFieldStyle(.roundedBorder)
                .font(.body)
        }
    }

    // MARK: - Complete

    private var completeContent: some View {
        VStack(spacing: 16) {
            Text("🎉")
                .font(.system(size: 80))
            Text("준비 완료!")
                .font(.largeTitle.bold())
            Text("이제 맞춤 추천을 시작할게요")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private func stepHeader(_ step: OnboardingStep) -> some View {
        VStack(spacing: 8) {
            Text(step.title)
                .font(.title2.bold())
            Text(step.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if viewModel.currentStep != .welcome && viewModel.currentStep != .complete {
                Button("이전") {
                    viewModel.previousStep()
                }
                .buttonStyle(.bordered)
            }

            Button(viewModel.currentStep == .complete ? "시작하기" :
                   viewModel.currentStep == .welcome ? "시작" :
                   (viewModel.currentStep == .budget || viewModel.currentStep == .dislikes) ? "건너뛰기 / 다음" : "다음") {
                if viewModel.currentStep == .complete {
                    viewModel.saveProfile(to: modelContext)
                    onComplete()
                } else {
                    viewModel.nextStep()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!viewModel.canProceed)
        }
    }

    private func toggleSelection<T: Hashable>(_ set: inout Set<T>, _ item: T) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }
}

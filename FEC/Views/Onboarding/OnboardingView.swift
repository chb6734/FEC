//
//  OnboardingView.swift
//  FEC
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
            // Brand
            Text("FEC")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(AppDesign.navy)
                .padding(.top, 40)

            // Progress Bar
            progressBar
                .padding(.top, 16)
                .padding(.horizontal, AppDesign.horizontalPadding)

            // Question
            Text(viewModel.currentStep.title)
                .font(.title2.bold())
                .foregroundStyle(AppDesign.navy)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 28)
                .padding(.horizontal, AppDesign.horizontalPadding)

            // Subtitle
            if !viewModel.currentStep.subtitle.isEmpty {
                Text(viewModel.currentStep.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppDesign.subtitleGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                    .padding(.horizontal, AppDesign.horizontalPadding)
            }

            // Content
            Group {
                switch viewModel.currentStep {
                case .mealPattern:
                    mealPatternContent
                case .restrictions:
                    restrictionsContent
                case .categories:
                    categoriesContent
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, AppDesign.horizontalPadding)

            Spacer()

            // CTA Button
            ctaButton
                .padding(.horizontal, AppDesign.horizontalPadding)
                .padding(.bottom, 40)
        }
        .background(AppDesign.beige.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
    }

    // MARK: - Progress Bar (3 segments)

    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<OnboardingStep.totalSteps, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= viewModel.currentStep.rawValue ? AppDesign.navy : AppDesign.chipBorder)
                    .frame(height: 3)
            }
        }
    }

    // MARK: - Meal Pattern (Full-width list buttons)

    private var mealPatternContent: some View {
        VStack(spacing: 12) {
            ForEach(MealType.allCases) { type in
                let isSelected = viewModel.selectedMealPatterns.contains(type)
                Button {
                    toggleSelection(&viewModel.selectedMealPatterns, type)
                } label: {
                    Text("\(type.displayName) (\(String(format: "%02d:00", type.startHour)) - \(String(format: "%02d:00", type.endHour)))")
                        .font(.body.weight(.medium))
                        .foregroundStyle(isSelected ? .white : AppDesign.navy)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(isSelected ? AppDesign.navy : AppDesign.cardWhite)
                        .clipShape(RoundedRectangle(cornerRadius: AppDesign.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppDesign.cornerRadius)
                                .stroke(isSelected ? AppDesign.navy : AppDesign.chipBorder, lineWidth: 1)
                        )
                }
            }
        }
    }

    // MARK: - Restrictions (Capsule chips)

    private var restrictionsContent: some View {
        FlowLayout(spacing: 10) {
            ForEach(DietaryRestriction.allCases) { restriction in
                let isSelected = viewModel.selectedRestrictions.contains(restriction)
                Button {
                    toggleSelection(&viewModel.selectedRestrictions, restriction)
                } label: {
                    Text(restriction.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(isSelected ? .white : AppDesign.navy)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(isSelected ? AppDesign.navy : AppDesign.cardWhite)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? AppDesign.navy : AppDesign.chipBorder, lineWidth: 1)
                        )
                }
            }
        }
    }

    // MARK: - Categories (2-column grid)

    private var categoriesContent: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(FoodCategory.onboardingCases) { category in
                let isSelected = viewModel.selectedCategories.contains(category)
                Button {
                    toggleSelection(&viewModel.selectedCategories, category)
                } label: {
                    Text(category.displayName)
                        .font(.body.weight(.medium))
                        .foregroundStyle(isSelected ? .white : AppDesign.navy)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isSelected ? AppDesign.navy : AppDesign.cardWhite)
                        .clipShape(RoundedRectangle(cornerRadius: AppDesign.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppDesign.cornerRadius)
                                .stroke(isSelected ? AppDesign.navy : AppDesign.chipBorder, lineWidth: 1)
                        )
                }
            }
        }
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button {
            if viewModel.isLastStep {
                viewModel.saveProfile(to: modelContext)
                onComplete()
            } else {
                viewModel.nextStep()
            }
        } label: {
            Text(viewModel.isLastStep ? "시작하기" : "다음")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(viewModel.canProceed ? AppDesign.navy : AppDesign.disabledButton)
                .clipShape(RoundedRectangle(cornerRadius: AppDesign.cornerRadius))
        }
        .disabled(!viewModel.canProceed)
    }

    // MARK: - Helpers

    private func toggleSelection<T: Hashable>(_ set: inout Set<T>, _ item: T) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }
}

#Preview("온보딩") {
    OnboardingView(onComplete: {})
        .modelContainer(for: [UserProfile.self, MealLog.self, FeedbackRecord.self, FoodItemEntity.self], inMemory: true)
}

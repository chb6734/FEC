//
//  SettingsView.swift
//  FEC
//
//  Created by Maya Designer & Dohyun iOS Engineer
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealLog.timestamp, order: .reverse) private var logs: [MealLog]
    @State private var showEditSheet = false
    @State private var showResetAlert = false
    let profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Profile Section
                sectionHeader("내 식사 프로필")
                profileCard

                // MARK: - Activity Section
                sectionHeader("내 활동")
                activityCard

                Divider()
                    .padding(.horizontal)

                // MARK: - Reset Button
                resetButton
                    .padding(.top, 8)
            }
            .padding(.vertical, 16)
        }
        .background(AppDesign.beige.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("수정") {
                    showEditSheet = true
                }
                .foregroundStyle(AppDesign.navy)
                .fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationStack {
                SettingsEditView(profile: profile)
            }
        }
        .alert("초기화", isPresented: $showResetAlert) {
            Button("취소", role: .cancel) {}
            Button("초기화", role: .destructive) {
                resetProfile()
            }
        } message: {
            Text("모든 프로필과 식사 기록이 삭제됩니다. 계속하시겠습니까?")
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(AppDesign.navy)
            .padding(.horizontal, 20)
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Meal Time
            profileRow(
                label: "식사 시간대",
                chips: profile.mealPattern.map { $0.displayName }
            )

            // Dietary Restrictions
            profileRow(
                label: "식이 제한",
                chips: profile.restrictions.map { $0.displayName }
            )

            // Preferred Categories
            profileRow(
                label: "선호 요리",
                chips: profile.preferredCategories.map { $0.displayName }
            )

            // Budget (if set)
            if let budget = profile.budget {
                profileRow(
                    label: "식사 비용대",
                    chips: [budget.displayName]
                )
            }

            // Dislikes (if any)
            if !profile.dislikes.isEmpty {
                profileRow(
                    label: "싫어하는 음식",
                    chips: profile.dislikes
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppDesign.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: AppDesign.cornerRadius))
        .padding(.horizontal, 20)
    }

    private func profileRow(label: String, chips: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppDesign.navy)

            FlowLayout(spacing: 8) {
                ForEach(chips, id: \.self) { chip in
                    Text(chip)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppDesign.navy)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppDesign.chipBorder.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: AppDesign.cornerRadius))
                }
            }
        }
    }

    // MARK: - Activity Card

    private var activityCard: some View {
        HStack {
            Text("기록된 식사 횟수")
                .font(.body)
                .foregroundStyle(AppDesign.navy)

            Spacer()

            Text("\(logs.count)번")
                .font(.title2.bold())
                .foregroundStyle(AppDesign.navy)
        }
        .padding(20)
        .background(AppDesign.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: AppDesign.cornerRadius))
        .padding(.horizontal, 20)
    }

    // MARK: - Reset Button

    private var resetButton: some View {
        Button {
            showResetAlert = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                Text("초기화 및 다시 시작하기")
            }
            .font(.body.weight(.medium))
            .foregroundStyle(AppDesign.resetRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppDesign.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: AppDesign.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppDesign.cornerRadius)
                    .stroke(AppDesign.resetRed.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Reset Action

    private func resetProfile() {
        profile.hasCompletedOnboarding = false
        profile.mealPatternRaw = []
        profile.restrictionsRaw = []
        profile.preferredCategoriesRaw = []
        profile.dislikes = []
        profile.budgetRaw = nil
        for log in logs {
            modelContext.delete(log)
        }
        dismiss()
    }
}

// MARK: - Settings Edit View (Sheet)

struct SettingsEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SettingsViewModel()
    @State private var showSavedAlert = false
    let profile: UserProfile

    var body: some View {
        Form {
            Section("식사 시간대") {
                FlowLayout(spacing: 10) {
                    ForEach(MealType.allCases) { type in
                        ChipButton(
                            title: "\(type.emoji) \(type.displayName)",
                            isSelected: viewModel.selectedMealPatterns.contains(type)
                        ) {
                            toggle(&viewModel.selectedMealPatterns, type)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("식이 제한사항") {
                FlowLayout(spacing: 10) {
                    ForEach(DietaryRestriction.allCases) { restriction in
                        ChipButton(
                            title: restriction.displayName,
                            isSelected: viewModel.selectedRestrictions.contains(restriction)
                        ) {
                            toggle(&viewModel.selectedRestrictions, restriction)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("선호 요리군") {
                FlowLayout(spacing: 10) {
                    ForEach(FoodCategory.allCases) { category in
                        ChipButton(
                            title: "\(category.emoji) \(category.displayName)",
                            isSelected: viewModel.selectedCategories.contains(category)
                        ) {
                            toggle(&viewModel.selectedCategories, category)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("싫어하는 음식") {
                TextField("쉼표로 구분 (예: 고수, 파)", text: $viewModel.dislikeText)
            }
        }
        .navigationTitle("프로필 수정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") {
                    viewModel.save(to: profile)
                    showSavedAlert = true
                }
                .disabled(!viewModel.canSave)
            }
        }
        .alert("저장 완료", isPresented: $showSavedAlert) {
            Button("확인") { dismiss() }
        } message: {
            Text("설정이 업데이트되었습니다")
        }
        .onAppear {
            viewModel.loadFrom(profile: profile)
        }
    }

    private func toggle<T: Hashable>(_ set: inout Set<T>, _ item: T) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }
}

// MARK: - Preview

private func makePreviewContainer() -> (ModelContainer, UserProfile) {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: UserProfile.self, MealLog.self,
        configurations: config
    )
    let profile = UserProfile()
    profile.hasCompletedOnboarding = true
    profile.mealPatternRaw = [MealType.breakfast.rawValue, MealType.lunch.rawValue, MealType.dinner.rawValue]
    profile.restrictionsRaw = [DietaryRestriction.vegetarian.rawValue]
    profile.preferredCategoriesRaw = [FoodCategory.korean.rawValue, FoodCategory.japanese.rawValue]
    profile.dislikes = ["고수", "파"]
    profile.budgetRaw = BudgetRange.medium.rawValue
    container.mainContext.insert(profile)
    let log1 = MealLog(foodName: "비빔밥", mealType: .lunch, timestamp: Date())
    let log2 = MealLog(foodName: "라면", mealType: .dinner, timestamp: Date())
    container.mainContext.insert(log1)
    container.mainContext.insert(log2)
    return (container, profile)
}

#Preview("세팅 화면") {
    let (container, profile) = makePreviewContainer()
    NavigationStack {
        SettingsView(profile: profile)
            .modelContainer(container)
    }
}

#Preview("프로필 수정 화면") {
    let (_, profile) = makePreviewContainer()
    NavigationStack {
        SettingsEditView(profile: profile)
    }
}

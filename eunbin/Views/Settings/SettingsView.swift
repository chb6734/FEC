//
//  SettingsView.swift
//  eunbin
//
//  Created by Maya Designer & Dohyun iOS Engineer
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SettingsViewModel()
    @State private var showSavedAlert = false
    let profile: UserProfile

    var body: some View {
        Form {
            // Meal Pattern
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

            // Dietary Restrictions
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

            // Preferred Categories
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

            // Dislikes
            Section("싫어하는 음식") {
                TextField("쉼표로 구분 (예: 고수, 파)", text: $viewModel.dislikeText)
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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

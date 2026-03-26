//
//  MealLoggingView.swift
//  eunbin
//
//  Created by Maya Designer & Dohyun iOS Engineer
//

import SwiftUI
import SwiftData

struct MealLoggingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MealLoggingViewModel
    let onComplete: () -> Void

    init(food: FoodItem? = nil, onComplete: @escaping () -> Void) {
        _viewModel = State(initialValue: MealLoggingViewModel(food: food))
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if viewModel.isSaved {
                    savedConfirmation
                } else {
                    loggingForm
                }
            }
            .padding(24)
            .navigationTitle(viewModel.isFromRecommendation ? "식사 기록" : "직접 입력")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !viewModel.isSaved {
                        Button("취소") { dismiss() }
                    }
                }
            }
        }
    }

    // MARK: - Logging Form

    private var loggingForm: some View {
        VStack(spacing: 20) {
            // Food Name
            VStack(alignment: .leading, spacing: 8) {
                Text("음식 이름")
                    .font(.subheadline.weight(.medium))
                TextField("무엇을 드셨나요?", text: $viewModel.foodName)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isFromRecommendation)
            }

            // Meal Type
            VStack(alignment: .leading, spacing: 8) {
                Text("식사 시간대")
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 12) {
                    ForEach(MealType.allCases) { type in
                        ChipButton(
                            title: "\(type.emoji) \(type.displayName)",
                            isSelected: viewModel.selectedMealType == type
                        ) {
                            viewModel.selectedMealType = type
                        }
                    }
                }
            }

            // Note
            VStack(alignment: .leading, spacing: 8) {
                Text("메모 (선택)")
                    .font(.subheadline.weight(.medium))
                TextField("한 줄 메모를 남겨보세요", text: $viewModel.note)
                    .textFieldStyle(.roundedBorder)
            }

            Spacer()

            // Save Button
            Button {
                viewModel.save(to: modelContext)
            } label: {
                Text("기록하기")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!viewModel.canSave)
        }
    }

    // MARK: - Saved Confirmation

    private var savedConfirmation: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("✅")
                .font(.system(size: 60))
            Text("기록 완료!")
                .font(.title2.bold())
            Text("\(viewModel.foodName)을(를) 기록했어요")
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
            Button("확인") {
                onComplete()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
    }
}

#Preview("추천 메뉴 기록") {
    MealLoggingView(
        food: FoodItem(
            id: "bibimbap",
            name: "비빔밥",
            category: .korean,
            mealTypes: [.lunch, .dinner],
            restrictions: [],
            tags: ["건강"],
            baseScore: 0.8
        ),
        onComplete: {}
    )
    .modelContainer(for: [MealLog.self], inMemory: true)
}

#Preview("직접 입력") {
    MealLoggingView(onComplete: {})
        .modelContainer(for: [MealLog.self], inMemory: true)
}

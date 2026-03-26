//
//  ContentView.swift
//  FEC
//
//  Created by 차현빈 on 3/4/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @AppStorage("hasCompletedOnboarding") private var onboardingDone = false

    private var hasCompletedOnboarding: Bool {
        onboardingDone || profiles.first?.hasCompletedOnboarding == true
    }

    var body: some View {
        if hasCompletedOnboarding {
            RecommendationView()
        } else {
            OnboardingView {
                onboardingDone = true
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, MealLog.self, FeedbackRecord.self, FoodItemEntity.self], inMemory: true)
}

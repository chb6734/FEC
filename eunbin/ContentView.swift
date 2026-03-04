//
//  ContentView.swift
//  eunbin
//
//  Created by 차현빈 on 3/4/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var hasCompletedOnboarding: Bool {
        profiles.first?.hasCompletedOnboarding == true
    }

    var body: some View {
        if hasCompletedOnboarding {
            RecommendationView()
        } else {
            OnboardingView {
                // Profile is saved inside OnboardingView
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, MealLog.self, FeedbackRecord.self], inMemory: true)
}

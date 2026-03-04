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
    @State private var showOnboarding = false

    private var hasCompletedOnboarding: Bool {
        profiles.first?.hasCompletedOnboarding == true
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                Text("메인 추천 화면 (준비 중)")
                    .font(.title)
            } else {
                OnboardingView {
                    showOnboarding = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, MealLog.self], inMemory: true)
}

//
//  FECApp.swift
//  FEC
//
//  Created by 차현빈 on 3/4/26.
//

import SwiftUI
import SwiftData

@main
struct FECApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            MealLog.self,
            FeedbackRecord.self,
            FoodItemEntity.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var isAuthenticated = false
    @State private var isCheckingAuth = true
    private let supabaseService = SupabaseService()

    var body: some Scene {
        WindowGroup {
            Group {
                if isCheckingAuth {
                    ZStack {
                        AppDesign.beige.ignoresSafeArea()
                        ProgressView()
                    }
                } else if isAuthenticated {
                    ContentView()
                        .onAppear {
                            seedDatabase()
                        }
                } else {
                    AuthView {
                        // 로그인 후 Supabase 프로필 동기화 완료 → 화면 전환
                        Task {
                            await syncProfileFromSupabase()
                            isAuthenticated = true
                        }
                    }
                }
            }
            .task {
                isAuthenticated = await supabaseService.isAuthenticated()
                if isAuthenticated {
                    await syncProfileFromSupabase()
                }
                isCheckingAuth = false
            }
        }
        .modelContainer(sharedModelContainer)
    }

    private func syncProfileFromSupabase() async {
        let context = sharedModelContainer.mainContext

        // 이미 로컬 프로필이 있으면 스킵
        let descriptor = FetchDescriptor<UserProfile>()
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            return
        }

        // Supabase에서 프로필 가져와서 로컬에 저장
        do {
            if let supabaseProfile = try await supabaseService.fetchProfile(),
               supabaseProfile.hasCompletedOnboarding {
                let localProfile = UserProfile()
                localProfile.mealPatternRaw = supabaseProfile.mealPatterns
                localProfile.restrictionsRaw = supabaseProfile.restrictions
                localProfile.preferredCategoriesRaw = supabaseProfile.preferredCategories
                localProfile.dislikes = supabaseProfile.dislikes
                localProfile.budgetRaw = supabaseProfile.budget
                localProfile.hasCompletedOnboarding = true
                context.insert(localProfile)
                try context.save()
            }
        } catch {
            print("Failed to sync profile from Supabase: \(error)")
        }
    }

    private func seedDatabase() {
        let context = sharedModelContainer.mainContext
        let service = FoodDataService(modelContext: context)
        do {
            try service.seedIfNeeded()
        } catch {
            print("Failed to seed local food database: \(error)")
        }

        Task {
            do {
                try await supabaseService.seedFoodsFromJSON()
            } catch {
                print("Failed to seed Supabase food database: \(error)")
            }
        }
    }
}

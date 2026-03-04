//
//  eunbinApp.swift
//  eunbin
//
//  Created by 차현빈 on 3/4/26.
//

import SwiftUI
import SwiftData

@main
struct eunbinApp: App {
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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    seedDatabase()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func seedDatabase() {
        let context = sharedModelContainer.mainContext
        let service = FoodDataService(modelContext: context)
        do {
            try service.seedIfNeeded()
        } catch {
            print("Failed to seed food database: \(error)")
        }
    }
}

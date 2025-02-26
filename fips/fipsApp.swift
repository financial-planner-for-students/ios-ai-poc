//
//  fipsApp.swift
//  fips
//
//  Created by Jason Tan on 2025-01-26.
//

import SwiftUI
import SwiftData

@main
struct fipsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            RootView {
                HomeView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

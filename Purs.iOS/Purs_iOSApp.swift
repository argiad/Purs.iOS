//
//  Purs_iOSApp.swift
//  Purs.iOS
//
//  Created by Artem Mkrtchyan on 1/9/24.
//

import SwiftUI
import SwiftData

@main
struct Purs_iOSApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LocationSchedule.self
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
        }
        .modelContainer(sharedModelContainer)
    }
}

//
//  VakeelNowApp.swift
//  VakeelNow
//
//  Created by Shivansh Jasathi on 28/10/25.
//

import SwiftUI

@main
struct VakeelNowApp: App {
    // Create the services here as "StateObjects" so they persist for the app's lifetime
    @StateObject private var repository = ConversationRepository()
    @StateObject private var ttsService = TextToSpeechService()

    // Get the saved dark mode setting
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Inject the services into the environment so ContentView and its children can see them
                .environmentObject(repository)
                .environmentObject(ttsService)
                // Apply the dark/light mode preference
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}


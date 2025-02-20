//
//  SmolLensApp.swift
//  SmolLens
//
//  Created by Rudrank Riyam on 2/20/25.
//

import SwiftUI

@main
struct SmolLensApp: App {
    @State private var modelLoader = ModelLoader()
    @State private var showOnboarding = true

    var body: some Scene {
        WindowGroup {
            CameraView()
                .ignoresSafeArea()
                .overlay {
                    if showOnboarding {
                        OnboardingView(showOnboarding: $showOnboarding)
                            .environment(modelLoader)
                    }
                }
                .animation(.easeInOut(duration: 1.0), value: showOnboarding)
        }
    }
}

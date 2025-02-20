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

    var body: some Scene {
        WindowGroup {
            CameraView()
                .overlay {
                    OnboardingView()
                        .environment(modelLoader)
                }
        }
    }
}

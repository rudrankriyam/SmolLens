import SwiftUI

@main
struct SmolLensApp: App {
    @State private var modelLoader = ModelLoader()
    @State private var showOnboarding = true

    var body: some Scene {
        WindowGroup {
            CameraContainerView()
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

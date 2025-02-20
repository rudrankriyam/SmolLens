import SwiftUI

@main
struct SmolLensApp: App {
    @State private var modelLoader = ModelLoader()
    @State private var showOnboarding = true

    var body: some Scene {
        WindowGroup {
            CameraContainerView()
                .overlay {
                    if showOnboarding {
                        OnboardingView(showOnboarding: $showOnboarding)
                            .environment(modelLoader)
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: showOnboarding)
        }
    }
}

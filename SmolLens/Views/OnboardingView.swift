import SwiftUI

struct OnboardingView: View {
    // Initialize the ModelLoader
    @State private var modelLoader = ModelLoader()
    @State private var shouldNavigateToMainApp = false

    var body: some View {
        ZStack {
            // Background blur effect
            Color.black
                .opacity(0.2)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack {
                Spacer()

                Text("Visual Intelligence")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.indigo.gradient)

                VStack(spacing: 16) {
                    Text(
                        "Learn about the objects and places around you and get information about what you see"
                    )
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                    Text(
                        "Photos and videos used are processed entirely on your device. No data is sent to the cloud."
                    )
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                }

                Spacer()

                Group {
                    switch modelLoader.loadState {
                    case .idle:
                        ProgressView()

                    case .loading(let progress):
                        HStack {
                            ProgressView()

                            Text("Downloading model... \(Int(progress * 100))%")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                    case .loaded:
                        // Navigate to main app
                        Text("Ready to explore!")
                            .font(.headline)
                            .foregroundColor(.green)

                    case .error(let error):
                        VStack(spacing: 8) {
                            Text("Error loading model")
                                .font(.headline)
                                .foregroundColor(.red)

                            Text(error.localizedDescription)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .task {
            do {
                _ = try await modelLoader.load()
                shouldNavigateToMainApp = true
            } catch {
                print("Error loading model: \(error)")
            }
        }
    }
}

#Preview {
    OnboardingView()
}

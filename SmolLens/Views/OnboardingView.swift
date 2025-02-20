import SwiftUI

struct OnboardingView: View {
    @Environment(ModelLoader.self) var modelLoader
    @Environment(\.dismiss) private var dismiss
    @Binding private var showOnboarding: Bool

    init(showOnboarding: Binding<Bool>) {
        _showOnboarding = showOnboarding
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.7)
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
                    .foregroundStyle(.white.gradient)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                    Text(
                        "Photos and videos used are processed entirely on your device. No data is sent to the cloud."
                    )
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
                }

                Spacer()

                Group {
                    switch modelLoader.loadState {
                    case .idle:
                        ProgressView()
                            .tint(.white)

                    case .loading(let progress):
                        HStack {
                            ProgressView()
                                .tint(.white)

                            Text("Downloading model... \(Int(progress * 100))%")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }

                    case .loaded:
                        Color.clear
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showOnboarding = false
                                }
                            }

                    case .error(let error):
                        HStack {
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
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .task {
            do {
                _ = try await modelLoader.load()
            } catch {
                print("Error loading model: \(error)")
            }
        }
    }
}

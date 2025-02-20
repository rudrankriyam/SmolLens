import SwiftUI

struct CameraControlsView: View {
    var isCaptured: Bool
    var onCapture: () -> Void

    @State private var rotationInner: Double = 0
    @State private var isGlowing = false

    var body: some View {
        Button(action: onCapture) {
            if isCaptured {
                Image(systemName: "xmark")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white.gradient)
                    .frame(width: 75, height: 75)
                    .clipShape(Circle())
                    .overlay(
                        ZStack {
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            .cyan.opacity(0.2),
                                            .indigo.opacity(0.5),
                                        ]),
                                        center: .center
                                    ),
                                    lineWidth: 5
                                )
                                .frame(width: 90, height: 90)
                                .rotationEffect(.degrees(rotationInner))
                        }
                    )
            } else {
                Circle()
                    .foregroundStyle(.white.gradient)
                    .frame(width: 75, height: 75)
                    .overlay(
                        ZStack {
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            .indigo.opacity(0.2),
                                            .purple.opacity(0.5),
                                        ]),
                                        center: .center
                                    ),
                                    lineWidth: 5
                                )
                                .frame(width: 90, height: 90)
                                .rotationEffect(.degrees(rotationInner))
                        }
                    )
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 15)
                    .repeatForever(autoreverses: false)
            ) {
                rotationInner = -360
            }

            withAnimation(
                .easeInOut(duration: 2.5)
                    .repeatForever(autoreverses: true)
            ) {
                isGlowing = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black

        CameraControlsView(
            isCaptured: false,
            onCapture: {
            }
        )
    }
}

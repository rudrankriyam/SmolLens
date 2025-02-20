import SwiftUI

struct CameraControlsView: View {
    var isCaptured: Bool
    var onCapture: () -> Void

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                Button(action: onCapture) {
                    if isCaptured {
                        Image(systemName: "xmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 70, height: 70)
                            .background(Color.red)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 2)
                                    .frame(width: 65, height: 65)
                            )
                    } else {
                        Circle()
                            .fill(.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 2)
                                    .frame(width: 65, height: 65)
                            )
                    }
                }

                Spacer()
            }
            .padding(.bottom, 30)
        }
    }
}

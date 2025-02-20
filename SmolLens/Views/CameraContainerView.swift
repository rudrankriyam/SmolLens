import SwiftUI

struct CameraContainerView: View {
    var body: some View {
        ZStack {
            CameraView()
                .ignoresSafeArea()

            CameraControlsView {
                // Handle capture action
                print("Photo captured")
            }
        }
    }
}

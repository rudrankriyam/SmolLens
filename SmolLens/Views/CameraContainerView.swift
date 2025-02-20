import SwiftUI

struct CameraContainerView: View {
    @StateObject private var camera = CameraModel()
    
    var body: some View {
        ZStack {
            CameraView(camera: camera)
                .ignoresSafeArea()

            CameraControlsView {
                if camera.isCaptured {
                    // Reset camera to take another photo
                    camera.isCaptured = false
                    camera.session.startRunning()
                } else {
                    // Capture new photo
                    camera.capturePhoto()
                }
            }
        }
    }
}

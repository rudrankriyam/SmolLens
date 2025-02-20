import SwiftUI

struct CameraContainerView: View {
    @StateObject private var camera = CameraModel()
    
    var body: some View {
        ZStack {
            CameraView(camera: camera)
                .ignoresSafeArea()
            
            CameraControlsView {
                if camera.isCaptured {
                    camera.isCaptured = false
                    camera.capturedImage = nil
                    DispatchQueue.global(qos: .background).async {
                        camera.session.startRunning()
                    }
                } else {
                    camera.capturePhoto()
                }
            }
        }
    }
}

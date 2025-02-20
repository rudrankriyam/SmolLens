import AVFoundation
import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var camera: CameraModel

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        return viewController
    }

    func updateUIViewController(
        _ uiViewController: UIViewController, context: Context
    ) {}

    class Coordinator: NSObject {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

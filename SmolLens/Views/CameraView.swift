import AVFoundation
import SwiftUI

struct CameraView: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let viewController = UIView()
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard
            let videoCaptureDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: .back)
        else {
            return viewController
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }

        camera.preview = AVCaptureVideoPreviewLayer(session: captureSession)
        camera.preview.frame = viewController.frame
        camera.preview.videoGravity = .resizeAspectFill
        viewController.layer.addSublayer(camera.preview)

        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }

        return viewController
    }

    func updateUIView(
        _ uiView: UIView, context: Context
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

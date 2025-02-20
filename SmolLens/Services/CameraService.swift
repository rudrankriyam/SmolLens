import AVFoundation
import OSLog
import SwiftUI

class CameraService: NSObject, ObservableObject {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.smollens",
        category: "CameraModel")

    @Published var session: AVCaptureSession
    @Published var alert = false
    @Published var isCaptured = false
    @Published var capturedImage: UIImage?

    // Photo output
    private let output = AVCapturePhotoOutput()

    // Add completion handler for photo capture
    var photoCaptureCompletion: (() -> Void)?

    override init() {
        self.session = AVCaptureSession()
        super.init()
        checkPermissions()
    }

    func checkPermissions() {
        logger.debug("Checking camera permissions")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            logger.info("Camera access authorized")
            setUp()
            return
        case .notDetermined:
            logger.info("Requesting camera access")
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    DispatchQueue.main.async {
                        self.setUp()
                    }
                }
            }
        case .denied:
            logger.warning("Camera access denied")
            self.alert.toggle()
            return
        default:
            logger.error("Unexpected camera authorization status")
            return
        }
    }

    private func setUp() {
        do {
            logger.debug("Setting up camera session")
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            self.session.inputs.forEach { session.removeInput($0) }
            self.session.outputs.forEach { session.removeOutput($0) }

            guard
                let device = AVCaptureDevice.default(
                    .builtInWideAngleCamera, for: .video, position: .back)
            else {
                logger.error("Failed to get camera device")
                return
            }

            let input = try AVCaptureDeviceInput(device: device)

            if self.session.canAddInput(input) {
                self.session.addInput(input)
                logger.debug("Added camera input")
            }

            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
                logger.debug("Added photo output")
            }

            self.session.commitConfiguration()

            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
                self.logger.info("Camera session started")
            }
        } catch {
            logger.error("Camera setup failed: \(error.localizedDescription)")
        }
    }

    func capturePhoto(completion: @escaping () -> Void) {
        logger.info("Initiating photo capture")
        self.photoCaptureCompletion = completion

        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(
                with: AVCapturePhotoSettings(), delegate: self)
        }
    }

    func reset() {
        logger.debug("Resetting camera for new capture")
        isCaptured = false
        capturedImage = nil
        DispatchQueue.global(qos: .background).async {
            self.logger.debug("Restarting camera session")
            self.session.startRunning()
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?
    ) {
        if let error = error {
            logger.error("Photo capture failed: \(error.localizedDescription)")
            return
        }

        if let imageData = photo.fileDataRepresentation() {
            self.capturedImage = UIImage(data: imageData)
            self.isCaptured = true
            self.session.stopRunning()
            logger.info("Photo captured successfully")

            // Call completion handler on main thread
            DispatchQueue.main.async {
                self.photoCaptureCompletion?()
            }
        } else {
            logger.error("Failed to process captured photo data")
        }
    }
}

import SwiftUI
import AVFoundation

class CameraModel: NSObject, ObservableObject {
    @Published var session: AVCaptureSession
    @Published var alert = false
    @Published var isCaptured = false
    @Published var capturedImage: UIImage?
    
    // Photo output
    private let output = AVCapturePhotoOutput()
    
    override init() {
        self.session = AVCaptureSession()
        super.init()
        checkPermissions()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    DispatchQueue.main.async {
                        self.setUp()
                    }
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    private func setUp() {
        do {
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            self.session.inputs.forEach { session.removeInput($0) }
            self.session.outputs.forEach { session.removeOutput($0) }
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
            let input = try AVCaptureDeviceInput(device: device)
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func capturePhoto() {
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            self.capturedImage = UIImage(data: imageData)
            self.isCaptured = true
            self.session.stopRunning()
        }
    }
}

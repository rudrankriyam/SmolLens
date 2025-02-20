import OSLog
import SwiftUI

struct CameraContainerView: View {
    @StateObject private var camera = CameraService()
    @StateObject private var analysisService: ImageAnalysisService

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.smollens",
        category: "CameraContainerView")

    init() {
        let vlmService = VLMService()
        _analysisService = StateObject(
            wrappedValue: ImageAnalysisService(vlmService: vlmService))
    }

    var body: some View {
        ZStack {
            CameraView(camera: camera)
                .ignoresSafeArea()

            CameraControlsView(isCaptured: camera.isCaptured) {
                if camera.isCaptured {
                    logger.debug("Resetting camera for new capture")
                    camera.reset()
                    analysisService.reset()
                } else {
                    logger.info("Initiating photo capture sequence")
                    camera.capturePhoto {
                        if let image = camera.capturedImage {
                            analysisService.analyzeImage(image)
                        }
                    }
                }
            }

            if let result = analysisService.analysisResult {
                ResultView(result: result)
                    .padding(.top)
                    .padding()
                    .animation(
                        .easeInOut(duration: 0.5),
                        value: analysisService.isAnalyzing)
            }

            if analysisService.isAnalyzing {
                VStack {
                    Spacer()

                    ProgressView("Analyzing Image...")
                        .padding()
                        .background(.ultraThickMaterial)
                        .cornerRadius(10)
                    Spacer()
                }
                .animation(
                    .easeInOut(duration: 0.5),
                    value: analysisService.isAnalyzing)
            }
        }
    }
}

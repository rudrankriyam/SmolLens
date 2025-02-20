import OSLog
import SwiftUI

struct CameraContainerView: View {
    @StateObject private var camera = CameraModel()
    @State private var modelLoader = ModelLoader()
    @State private var visionResult: String? = nil
    @State private var isAnalyzing = false

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.smollens",
        category: "CameraContainerView")

    var body: some View {
        ZStack {
            CameraView(camera: camera)
                .ignoresSafeArea()

            CameraControlsView {
                if camera.isCaptured {
                    logger.debug("Resetting camera for new capture")
                    camera.isCaptured = false
                    camera.capturedImage = nil
                    visionResult = nil
                    DispatchQueue.global(qos: .background).async {
                        logger.debug("Restarting camera session")
                        camera.session.startRunning()
                    }
                } else {
                    logger.info("Initiating photo capture sequence")
                    camera.capturePhoto {
                        logger.debug(
                            "Photo capture completed, starting processing")
                        processImage()
                    }
                }
            }

            if let result = visionResult {
                ResultView(result: result)
                    .padding(.top)
                    .padding()
                    .animation(.easeInOut(duration: 0.5), value: isAnalyzing)
            }

            if isAnalyzing {
                VStack {
                    Spacer()

                    ProgressView("Analyzing Image...")
                        .padding()
                        .background(.ultraThickMaterial)
                        .cornerRadius(10)
                    Spacer()
                }
                .animation(.easeInOut(duration: 0.5), value: isAnalyzing)
            }
        }
    }

    private func processImage() {
        guard let image = camera.capturedImage else {
            logger.error("Failed to process image: No captured image available")
            return
        }

        logger.info("Starting image analysis process")
        logger.debug(
            "Image dimensions: \(image.size.width)x\(image.size.height)")

        isAnalyzing = true
        Task {
            do {
                logger.debug("Sending image for VLM analysis")
                let analysisStartTime = Date()

                let result = try await modelLoader.analyze(image: image)

                let duration = Date().timeIntervalSince(analysisStartTime)
                logger.info(
                    "Analysis completed in \(String(format: "%.2f", duration)) seconds"
                )

                await MainActor.run {
                    withAnimation {
                        logger.debug("Updating UI with analysis results")
                        visionResult = result
                        isAnalyzing = false
                    }
                }
            } catch {
                logger.error("Analysis failed: \(error.localizedDescription)")
                await MainActor.run {
                    visionResult =
                        "Error analyzing image: \(error.localizedDescription)"
                    isAnalyzing = false
                }
            }
        }
    }
}

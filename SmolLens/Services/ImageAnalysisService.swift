import Foundation
import OSLog
import SwiftUI

protocol ImageAnalyzerProtocol {
    func analyze(image: UIImage, prompt: String?) async throws -> String
}

class ImageAnalysisService: ObservableObject {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.smollens",
        category: "ImageAnalysisService")

    @Published var isAnalyzing = false
    @Published var analysisResult: String?

    private var analysisTask: Task<Void, Never>?

    private let vlmService: VLMServiceProtocol

    init(vlmService: VLMServiceProtocol) {
        self.vlmService = vlmService
    }

    func analyzeImage(_ image: UIImage, prompt: String? = nil) {
        analysisTask?.cancel()

        logger.info("Starting image analysis process")
        logger.debug(
            "Image dimensions: \(image.size.width)x\(image.size.height)")

        isAnalyzing = true

        // Create new analysis task
        analysisTask = Task {
            do {
                logger.debug("Sending image for VLM analysis")
                let analysisStartTime = Date()

                if Task.isCancelled { return }

                let result = try await vlmService.analyze(image: image, prompt: prompt)

                if Task.isCancelled { return }

                let duration = Date().timeIntervalSince(analysisStartTime)
                logger.info(
                    "Analysis completed in \(String(format: "%.2f", duration)) seconds"
                )

                await MainActor.run {
                    withAnimation {
                        guard !Task.isCancelled else { return }
                        logger.debug("Updating UI with analysis results")
                        analysisResult = result
                        isAnalyzing = false
                    }
                }
            } catch {
                logger.error("Analysis failed: \(error.localizedDescription)")
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    analysisResult =
                        "Error analyzing image: \(error.localizedDescription)"
                    isAnalyzing = false
                }
            }
        }
    }

    func reset() {
        logger.info("Resetting analysis service and VLM service")

        analysisTask?.cancel()
        analysisTask = nil

        analysisResult = nil
        isAnalyzing = false
        vlmService.reset()
    }
}

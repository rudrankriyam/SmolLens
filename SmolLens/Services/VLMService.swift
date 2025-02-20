import CoreImage
import MLX
import MLXLMCommon
import MLXRandom
import MLXVLM
import OSLog
import SwiftUI

protocol VLMServiceProtocol: ImageAnalyzerProtocol {
    func analyze(image: UIImage, prompt: String?) async throws -> String
    func reset()
}

class VLMService: VLMServiceProtocol {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.smollens",
        category: "VLMService")
    private let modelLoader: ModelLoader

    init(modelLoader: ModelLoader = ModelLoader()) {
        self.modelLoader = modelLoader
    }

    func analyze(image: UIImage, prompt: String? = nil) async throws -> String {
        logger.info("Starting VLM analysis")
        return try await modelLoader.analyze(image: image, prompt: prompt)
    }

    func reset() {
        logger.info("Resetting VLMService")
        modelLoader.reset()
    }
}

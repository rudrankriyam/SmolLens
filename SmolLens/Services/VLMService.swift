import MLX
import MLXLMCommon
import MLXVLM
import SwiftUI
import CoreImage
import MLXRandom
import OSLog

protocol VLMServiceProtocol: ImageAnalyzerProtocol {
    func analyze(image: UIImage) async throws -> String
    func reset()
}

class VLMService: VLMServiceProtocol {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.smollens", category: "VLMService")
    private let modelLoader: ModelLoader
    
    init(modelLoader: ModelLoader = ModelLoader()) {
        self.modelLoader = modelLoader
    }
    
    func analyze(image: UIImage) async throws -> String {
        logger.info("Starting VLM analysis")
        return try await modelLoader.analyze(image: image)
    }
    
    func reset() {
        logger.info("Resetting VLMService")
        modelLoader.reset()
    }
}

import AppIntents
import UIKit
import Foundation
import OSLog
import VisualIntelligence
import CoreImage

@UnionValue
enum VisualSearchResult {
    case analysis(SmolLensEntity)
}

@available(iOS 26.0, *)
struct SmolLensVisualQuery: IntentValueQuery {
    typealias Value = VisualSearchResult
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.smollens",
        category: "SmolLensVisualQuery"
    )
    
    func values(for input: SemanticContentDescriptor) async throws -> [VisualSearchResult] {
        logger.info("Visual Intelligence query received")
        
        guard let pixelBuffer = input.pixelBuffer else {
            logger.warning("No pixel buffer provided in SemanticContentDescriptor")
            return []
        }
        
        do {
            // Create CIImage from the pixel buffer using withUnsafeBuffer
            let ciImage = pixelBuffer.withUnsafeBuffer { buffer in
                CIImage(cvImageBuffer: buffer)
            }
            logger.debug("Created CIImage from pixel buffer with size: \(ciImage.extent.size.width)x\(ciImage.extent.size.height)")
            
            // Initialize the VLM service
            let modelLoader = ModelLoader()
            let vlmService = VLMService(modelLoader: modelLoader)
            
            // Convert CIImage to UIImage for analysis
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                logger.error("Failed to create CGImage from CIImage")
                return []
            }
            
            let uiImage = UIImage(cgImage: cgImage)
            logger.debug("Converted to UIImage with size: \(uiImage.size.width)x\(uiImage.size.height)")
            
            // Analyze the image with SmolVLM
            let analysisResult = try await vlmService.analyze(
                image: uiImage, 
                prompt: "Describe what you see in this image concisely."
            )
            
            logger.info("Analysis completed successfully")
            
            // Create entity from analysis result
            let entity = SmolLensEntity(
                id: UUID().uuidString,
                analysisResult: analysisResult,
                confidence: 0.85, // Placeholder confidence
                timestamp: Date()
            )
            
            return [.analysis(entity)]
            
        } catch {
            logger.error("Visual Intelligence analysis failed: \(error.localizedDescription)")
            return []
        }
    }
}

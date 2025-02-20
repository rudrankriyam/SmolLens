import MLX
import MLXLMCommon
import MLXVLM
import SwiftUI
import CoreImage
import MLXRandom
import OSLog

@Observable
class ModelLoader {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.smollens", category: "ModelLoader")
    
    enum LoadState {
        case idle
        case loading(progress: Double)
        case loaded(ModelContainer)
        case error(Error)
    }

    var loadState = LoadState.idle
    var modelInfo = ""
    var output = ""
    var running = false

    let modelConfiguration = ModelRegistry.smolvlm
    let generateParameters = MLXLMCommon.GenerateParameters(temperature: 0.7, topP: 0.9)
    let maxTokens = 800

    func load() async throws -> ModelContainer {
        logger.info("Starting model load process. Current state: \(String(describing: self.loadState))")
        
        switch loadState {
        case .idle, .loading:
            logger.debug("Setting GPU cache limit to 20MB")
            MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)

            do {
                logger.info("Initiating model container load for configuration: \(self.modelConfiguration.name)")
                
                let modelContainer = try await VLMModelFactory.shared
                    .loadContainer(
                        configuration: modelConfiguration
                    ) { [modelConfiguration] progress in
                        Task { @MainActor in
                            self.loadState = .loading(
                                progress: progress.fractionCompleted)
                            self.modelInfo =
                                "Downloading \(modelConfiguration.name): \(Int(progress.fractionCompleted * 100))%"
                            self.logger.debug("Download progress: \(progress.fractionCompleted * 100)%")
                        }
                    }

                let numParams = await modelContainer.perform { context in
                    context.model.numParameters()
                }
                
                logger.info("Model loaded successfully. Parameters: \(numParams / (1024*1024))M")

                self.modelInfo =
                    "Loaded \(modelConfiguration.id). Weights: \(numParams / (1024*1024))M"
                self.loadState = .loaded(modelContainer)
                return modelContainer

            } catch {
                logger.error("Failed to load model: \(error.localizedDescription)")
                self.loadState = .error(error)
                throw error
            }

        case .loaded(let modelContainer):
            logger.debug("Returning previously loaded model container")
            return modelContainer

        case .error(let error):
            logger.error("Model in error state: \(error.localizedDescription)")
            throw error
        }
    }
    
    func analyze(image: UIImage) async throws -> String {
        logger.info("Starting image analysis")
        
        guard !running else {
            logger.warning("Analysis already in progress, skipping request")
            return "" 
        }
        
        running = true
        output = ""
        
        do {
            logger.debug("Loading model for analysis")
            let modelContainer = try await load()
            
            guard let ciImage = CIImage(image: image) else {
                logger.error("Failed to convert UIImage to CIImage")
                throw NSError(domain: "ModelLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
            }
            
            logger.debug("Setting random seed for inference")
            MLXRandom.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))
            
            let startTime = Date()
            logger.info("Starting model inference")
            
            let result = try await modelContainer.perform { context in
                let images: [UserInput.Image] = [UserInput.Image.ciImage(ciImage)]
                
                let messages: [Message] = [
                    [
                        "role": "system",
                        "content": [
                            [
                                "type": "text",
                                "text": "You are an image understanding model capable of describing the salient features of any image.",
                            ],
                        ]
                    ],
                    [
                        "role": "user",
                        "content": [
                            ["type": "image"],
                            ["type": "text", "text": "What do you see in this image? Summarize the image in a few sentences."]
                        ]
                    ]
                ]
                
                logger.debug("Preparing user input for inference")
                let userInput = UserInput(messages: messages, images: images, videos: [])
                let input = try await context.processor.prepare(input: userInput)
                
                logger.debug("Starting token generation")
                return try MLXLMCommon.generate(
                    input: input,
                    parameters: generateParameters,
                    context: context
                ) { tokens in
                    if tokens.count >= maxTokens {
                        logger.debug("Reached maximum token count: \(self.maxTokens)")
                        return .stop
                    } else {
                        return .more
                    }
                }
            }
            
            let duration = Date().timeIntervalSince(startTime)
            logger.info("Inference completed in \(String(format: "%.2f", duration)) seconds")
            
            running = false
            return result.output
            
        } catch {
            logger.error("Analysis failed: \(error.localizedDescription)")
            running = false
            throw error
        }
    }
}

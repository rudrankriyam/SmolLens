import MLX
import MLXLMCommon
import MLXVLM
import SwiftUI

@Observable
class ModelLoader {
    enum LoadState {
        case idle
        case loading(progress: Double)
        case loaded(ModelContainer)
        case error(Error)
    }

    var loadState = LoadState.idle
    var modelInfo = ""

    let modelConfiguration = ModelRegistry.smolvlm

    func load() async throws -> ModelContainer {
        switch loadState {
        case .idle, .loading:
            MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)

            do {
                let modelContainer = try await VLMModelFactory.shared
                    .loadContainer(
                        configuration: modelConfiguration
                    ) { [modelConfiguration] progress in
                        Task { @MainActor in
                            self.loadState = .loading(
                                progress: progress.fractionCompleted)
                            self.modelInfo =
                                "Downloading \(modelConfiguration.name): \(Int(progress.fractionCompleted * 100))%"
                        }
                    }

                let numParams = await modelContainer.perform { context in
                    context.model.numParameters()
                }

                self.modelInfo =
                    "Loaded \(modelConfiguration.id). Weights: \(numParams / (1024*1024))M"
                self.loadState = .loaded(modelContainer)
                return modelContainer

            } catch {
                self.loadState = .error(error)
                throw error
            }

        case .loaded(let modelContainer):
            return modelContainer

        case .error(let error):
            throw error
        }
    }
}

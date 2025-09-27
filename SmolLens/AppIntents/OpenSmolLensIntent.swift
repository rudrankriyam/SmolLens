import AppIntents
import Foundation
import VisualIntelligence

struct OpenSmolLensIntent: OpenIntent {
    static let title: LocalizedStringResource = "Open SmolLens Analysis"
    
    @Parameter(title: "Analysis")
    var target: SmolLensEntity
    
    func perform() async throws -> some IntentResult {
        // Open the app to show the analysis result
        // This could navigate to a specific view showing the analysis
        return .result()
    }
}

@available(iOS 26.0, *)
struct SmolLensSemanticSearchIntent: AppIntent {
    static var title: LocalizedStringResource = "Search with SmolLens"
    static var description = IntentDescription("Search for visual content using SmolLens analysis")
    static var parameterSummary: some ParameterSummary {
        Summary("Search with SmolLens using visual content")
    }
    
    @Parameter(title: "Visual Content")
    var descriptor: SemanticContentDescriptor
    
    func perform() async throws -> some IntentResult {
        // This intent allows users to access more detailed search results in the app
        // when they tap "More results" in Visual Intelligence
        return .result()
    }
}

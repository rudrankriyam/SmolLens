import AppIntents
import Foundation

struct SmolLensEntity: AppEntity {
    let id: String
    let analysisResult: String
    let confidence: Double
    let timestamp: Date
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("SmolLens Analysis", table: "AppIntents", comment: "The type name for SmolLens analysis entity"),
            numericFormat: "\(placeholder: .int) analyses"
        )
    }
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "Visual Analysis",
            subtitle: "\(analysisResult.prefix(80))\(analysisResult.count > 80 ? "..." : "")",
            image: .init(systemName: "camera.viewfinder")
        )
    }
    
    static var defaultQuery = SmolLensEntityQuery()
    
    // Required for AppEntity conformance
    static let typeIdentifier = "SmolLensEntity"
}

struct SmolLensEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [SmolLensEntity] {
        // Return entities for given identifiers if needed
        return []
    }
    
    func suggestedEntities() async throws -> [SmolLensEntity] {
        // Return suggested entities if needed
        return []
    }
}

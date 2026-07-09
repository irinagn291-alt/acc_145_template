import Foundation
import SwiftData

enum ModelContainerSetup {
    static func create() throws -> ModelContainer {
        let schema = Schema([
            PageRecordModel.self,
            ShelfRecordModel.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

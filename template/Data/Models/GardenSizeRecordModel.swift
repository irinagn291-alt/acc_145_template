import Foundation
import SwiftData

@Model
final class ShelfRecordModel {
    @Attribute(.unique) var id: UUID
    var effectiveDate: Date
    var shelfCount: Int
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID, effectiveDate: Date, shelfCount: Int, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.effectiveDate = effectiveDate
        self.shelfCount = shelfCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

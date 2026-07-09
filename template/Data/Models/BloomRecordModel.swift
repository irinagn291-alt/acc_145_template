import Foundation
import SwiftData

@Model
final class PageRecordModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var pageCount: Int
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID, date: Date, pageCount: Int, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.date = date
        self.pageCount = pageCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

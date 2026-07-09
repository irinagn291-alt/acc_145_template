import Foundation

struct ShelfRecord: Identifiable, Equatable, Sendable {
    let id: UUID
    let effectiveDate: Date
    let shelfCount: Int
    let createdAt: Date
    let updatedAt: Date
}

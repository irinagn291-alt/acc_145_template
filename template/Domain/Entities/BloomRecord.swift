import Foundation

struct PageRecord: Identifiable, Equatable, Sendable {
    let id: UUID
    let date: Date
    let pageCount: Int
    let createdAt: Date
    let updatedAt: Date
}

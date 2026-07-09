import Foundation

protocol ShelfRecordRepositoryProtocol {
    func fetchAll() async throws -> [ShelfRecord]
    func fetchForDate(_ date: Date) async throws -> ShelfRecord?
    func fetchCurrent() async throws -> ShelfRecord?
    func save(_ record: ShelfRecord) async throws
    func delete(_ record: ShelfRecord) async throws
    func hasPageRecordsBefore(nextEffectiveDate: Date, afterOrOn currentEffectiveDate: Date) async throws -> Bool
}

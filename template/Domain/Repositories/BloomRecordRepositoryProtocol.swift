import Foundation

protocol PageRecordRepositoryProtocol {
    func fetchAll() async throws -> [PageRecord]
    func fetchForDate(_ date: Date) async throws -> PageRecord?
    func fetchInRange(from startDate: Date, to endDate: Date) async throws -> [PageRecord]
    func save(_ record: PageRecord) async throws
    func delete(_ record: PageRecord) async throws
}

import Foundation

protocol GetShelfRecordForDateUseCaseProtocol {
    func execute(date: Date) async throws -> ShelfRecord?
}

struct GetShelfRecordForDateUseCase: GetShelfRecordForDateUseCaseProtocol {
    let shelfRepository: ShelfRecordRepositoryProtocol

    func execute(date: Date) async throws -> ShelfRecord? {
        try await shelfRepository.fetchForDate(DateNormalizer.startOfDay(date))
    }
}

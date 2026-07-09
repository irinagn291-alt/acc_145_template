import Foundation

protocol GetPageRecordForDateUseCaseProtocol {
    func execute(date: Date) async throws -> PageRecord?
}

struct GetPageRecordForDateUseCase: GetPageRecordForDateUseCaseProtocol {
    let pageRepository: PageRecordRepositoryProtocol

    func execute(date: Date) async throws -> PageRecord? {
        try await pageRepository.fetchForDate(DateNormalizer.startOfDay(date))
    }
}

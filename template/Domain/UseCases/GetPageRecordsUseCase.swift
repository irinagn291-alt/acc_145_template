import Foundation

protocol GetPageRecordsUseCaseProtocol {
    func execute() async throws -> [PageRecord]
}

struct GetPageRecordsUseCase: GetPageRecordsUseCaseProtocol {
    let pageRepository: PageRecordRepositoryProtocol

    func execute() async throws -> [PageRecord] {
        try await pageRepository.fetchAll()
    }
}

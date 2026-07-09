import Foundation

protocol DeletePageRecordUseCaseProtocol {
    func execute(_ record: PageRecord) async throws
}

struct DeletePageRecordUseCase: DeletePageRecordUseCaseProtocol {
    let pageRepository: PageRecordRepositoryProtocol

    func execute(_ record: PageRecord) async throws {
        try await pageRepository.delete(record)
    }
}

import Foundation

protocol GetCurrentShelfRecordUseCaseProtocol {
    func execute() async throws -> ShelfRecord?
}

struct GetCurrentShelfRecordUseCase: GetCurrentShelfRecordUseCaseProtocol {
    let shelfRepository: ShelfRecordRepositoryProtocol

    func execute() async throws -> ShelfRecord? {
        try await shelfRepository.fetchCurrent()
    }
}

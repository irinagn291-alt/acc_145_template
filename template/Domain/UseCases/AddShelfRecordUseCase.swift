import Foundation

protocol AddShelfRecordUseCaseProtocol {
    func execute(effectiveDate: Date, shelfCount: Int) async throws -> ShelfRecord
}

struct AddShelfRecordUseCase: AddShelfRecordUseCaseProtocol {
    let shelfRepository: ShelfRecordRepositoryProtocol

    func execute(effectiveDate: Date, shelfCount: Int) async throws -> ShelfRecord {
        let normalizedDate = DateNormalizer.startOfDay(effectiveDate)
        guard shelfCount > 0 else {
            throw PageTurnerError.invalidShelf
        }

        let now = Date()
        if let existing = try await shelfRepository.fetchForDate(normalizedDate),
           DateNormalizer.startOfDay(existing.effectiveDate) == normalizedDate {
            let updated = ShelfRecord(
                id: existing.id,
                effectiveDate: normalizedDate,
                shelfCount: shelfCount,
                createdAt: existing.createdAt,
                updatedAt: now
            )
            try await shelfRepository.save(updated)
            return updated
        } else {
            let newRecord = ShelfRecord(
                id: UUID(),
                effectiveDate: normalizedDate,
                shelfCount: shelfCount,
                createdAt: now,
                updatedAt: now
            )
            try await shelfRepository.save(newRecord)
            return newRecord
        }
    }
}

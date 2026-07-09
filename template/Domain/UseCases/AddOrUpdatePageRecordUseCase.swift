import Foundation

protocol AddOrUpdatePageRecordUseCaseProtocol {
    func execute(date: Date, pageCount: Int) async throws -> PageRecord
}

struct AddOrUpdatePageRecordUseCase: AddOrUpdatePageRecordUseCaseProtocol {
    let pageRepository: PageRecordRepositoryProtocol
    let shelfRepository: ShelfRecordRepositoryProtocol

    func execute(date: Date, pageCount: Int) async throws -> PageRecord {
        let normalizedDate = DateNormalizer.startOfDay(date)
        
        guard normalizedDate <= DateNormalizer.startOfDay(Date()) else {
            throw PageTurnerError.futureDateNotAllowed
        }
        guard pageCount >= 0 else {
            throw PageTurnerError.negativePageCount
        }
        guard let capacitySize = try await shelfRepository.fetchForDate(normalizedDate) else {
            throw PageTurnerError.noShelfForDate
        }
        let maxCount = capacitySize.shelfCount * 50
        guard pageCount <= maxCount else {
            throw PageTurnerError.pageCountExceedsMax(max: maxCount)
        }

        let now = Date()
        if let existing = try await pageRepository.fetchForDate(normalizedDate) {
            let updated = PageRecord(
                id: existing.id,
                date: normalizedDate,
                pageCount: pageCount,
                createdAt: existing.createdAt,
                updatedAt: now
            )
            try await pageRepository.save(updated)
            return updated
        } else {
            let newRecord = PageRecord(
                id: UUID(),
                date: normalizedDate,
                pageCount: pageCount,
                createdAt: now,
                updatedAt: now
            )
            try await pageRepository.save(newRecord)
            return newRecord
        }
    }
}

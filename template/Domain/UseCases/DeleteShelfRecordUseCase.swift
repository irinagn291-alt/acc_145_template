import Foundation

protocol DeleteShelfRecordUseCaseProtocol {
    func execute(_ record: ShelfRecord, allCapacityRecords: [ShelfRecord]) async throws
}

struct DeleteShelfRecordUseCase: DeleteShelfRecordUseCaseProtocol {
    let shelfRepository: ShelfRecordRepositoryProtocol

    func execute(_ record: ShelfRecord, allCapacityRecords: [ShelfRecord]) async throws {
        let sorted = allCapacityRecords.sorted { $0.effectiveDate < $1.effectiveDate }
        guard let index = sorted.firstIndex(where: { $0.id == record.id }) else {
            throw PageTurnerError.recordNotFound
        }

        let nextEffectiveDate: Date?
        if index + 1 < sorted.count {
            nextEffectiveDate = sorted[index + 1].effectiveDate
        } else {
            nextEffectiveDate = nil
        }

        if let nextDate = nextEffectiveDate {
            let hasOrphans = try await shelfRepository.hasPageRecordsBefore(
                nextEffectiveDate: nextDate,
                afterOrOn: record.effectiveDate
            )
            if hasOrphans {
                throw PageTurnerError.deletionWouldOrphanRecords
            }
        } else {
            let previousRecord = index > 0 ? sorted[index - 1] : nil
            if previousRecord == nil {
                let hasOrphans = try await shelfRepository.hasPageRecordsBefore(
                    nextEffectiveDate: Date.distantFuture,
                    afterOrOn: record.effectiveDate
                )
                if hasOrphans {
                    throw PageTurnerError.deletionWouldOrphanRecords
                }
            }
        }

        try await shelfRepository.delete(record)
    }
}

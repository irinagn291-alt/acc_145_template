import Foundation
import SwiftData

final class SwiftDataShelfRecordRepository: ShelfRecordRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() async throws -> [ShelfRecord] {
        let descriptor = FetchDescriptor<ShelfRecordModel>(sortBy: [SortDescriptor(\.effectiveDate, order: .reverse)])
        let models = try modelContext.fetch(descriptor)
        return models.map(EntityModelMapper.toEntity)
    }

    func fetchForDate(_ date: Date) async throws -> ShelfRecord? {
        let normalized = DateNormalizer.startOfDay(date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: normalized)!
        let predicate = #Predicate<ShelfRecordModel> { model in
            model.effectiveDate < nextDay
        }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.effectiveDate, order: .reverse)])
        let models = try modelContext.fetch(descriptor)
        return models.first.map(EntityModelMapper.toEntity)
    }

    func fetchCurrent() async throws -> ShelfRecord? {
        try await fetchForDate(Date())
    }

    func save(_ record: ShelfRecord) async throws {
        let recordId = record.id
        let predicate = #Predicate<ShelfRecordModel> { model in
            model.id == recordId
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        let existing = try modelContext.fetch(descriptor)

        if let model = existing.first {
            EntityModelMapper.updateModel(model, from: record)
        } else {
            let model = ShelfRecordModel(
                id: record.id,
                effectiveDate: record.effectiveDate,
                shelfCount: record.shelfCount,
                createdAt: record.createdAt,
                updatedAt: record.updatedAt
            )
            modelContext.insert(model)
        }
        try modelContext.save()
    }

    func delete(_ record: ShelfRecord) async throws {
        let recordId = record.id
        let predicate = #Predicate<ShelfRecordModel> { model in
            model.id == recordId
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }

    func hasPageRecordsBefore(nextEffectiveDate: Date, afterOrOn currentEffectiveDate: Date) async throws -> Bool {
        let predicate = #Predicate<PageRecordModel> { model in
            model.date >= currentEffectiveDate && model.date < nextEffectiveDate
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        let results = try modelContext.fetch(descriptor)
        return !results.isEmpty
    }
}

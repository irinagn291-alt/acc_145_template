import Foundation
import SwiftData

final class SwiftDataPageRecordRepository: PageRecordRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() async throws -> [PageRecord] {
        let descriptor = FetchDescriptor<PageRecordModel>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let models = try modelContext.fetch(descriptor)
        return models.map(EntityModelMapper.toEntity)
    }

    func fetchForDate(_ date: Date) async throws -> PageRecord? {
        let normalized = DateNormalizer.startOfDay(date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: normalized)!
        let predicate = #Predicate<PageRecordModel> { model in
            model.date >= normalized && model.date < nextDay
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        let models = try modelContext.fetch(descriptor)
        return models.first.map(EntityModelMapper.toEntity)
    }

    func fetchInRange(from startDate: Date, to endDate: Date) async throws -> [PageRecord] {
        let start = DateNormalizer.startOfDay(startDate)
        let end = DateNormalizer.startOfDay(endDate)
        let nextDayAfterEnd = Calendar.current.date(byAdding: .day, value: 1, to: end)!
        let predicate = #Predicate<PageRecordModel> { model in
            model.date >= start && model.date < nextDayAfterEnd
        }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.date)])
        let models = try modelContext.fetch(descriptor)
        return models.map(EntityModelMapper.toEntity)
    }

    func save(_ record: PageRecord) async throws {
        let recordId = record.id
        let predicate = #Predicate<PageRecordModel> { model in
            model.id == recordId
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        let existing = try modelContext.fetch(descriptor)

        if let model = existing.first {
            EntityModelMapper.updateModel(model, from: record)
        } else {
            let model = PageRecordModel(
                id: record.id,
                date: record.date,
                pageCount: record.pageCount,
                createdAt: record.createdAt,
                updatedAt: record.updatedAt
            )
            modelContext.insert(model)
        }
        try modelContext.save()
    }

    func delete(_ record: PageRecord) async throws {
        let recordId = record.id
        let predicate = #Predicate<PageRecordModel> { model in
            model.id == recordId
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }
}

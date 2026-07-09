import Foundation

enum EntityModelMapper {
    static func toEntity(_ model: PageRecordModel) -> PageRecord {
        PageRecord(
            id: model.id,
            date: model.date,
            pageCount: model.pageCount,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }

    static func toEntity(_ model: ShelfRecordModel) -> ShelfRecord {
        ShelfRecord(
            id: model.id,
            effectiveDate: model.effectiveDate,
            shelfCount: model.shelfCount,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }

    static func updateModel(_ model: PageRecordModel, from entity: PageRecord) {
        model.date = entity.date
        model.pageCount = entity.pageCount
        model.updatedAt = entity.updatedAt
    }

    static func updateModel(_ model: ShelfRecordModel, from entity: ShelfRecord) {
        model.effectiveDate = entity.effectiveDate
        model.shelfCount = entity.shelfCount
        model.updatedAt = entity.updatedAt
    }
}

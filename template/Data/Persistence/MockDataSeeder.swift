#if DEBUG
import Foundation
import SwiftData

enum MockDataSeeder {
    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        #if targetEnvironment(simulator)
        guard ((try? context.fetchCount(FetchDescriptor<PageRecordModel>())) ?? 0) == 0 else { return }

        let now = Date()
        let calendar = Calendar.current
        let today = DateNormalizer.startOfDay(now)

        if let oldDate = calendar.date(byAdding: .day, value: -30, to: today) {
            context.insert(ShelfRecordModel(
                id: UUID(),
                effectiveDate: oldDate,
                shelfCount: 2,
                createdAt: now,
                updatedAt: now
            ))
        }
        if let recentDate = calendar.date(byAdding: .day, value: -10, to: today) {
            context.insert(ShelfRecordModel(
                id: UUID(),
                effectiveDate: recentDate,
                shelfCount: 3,
                createdAt: now,
                updatedAt: now
            ))
        }

        let span = max(85 - 15, 1)
        for offset in 0..<28 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            if offset % 7 == 6 { continue }
            let wave = (offset * 11 + 5) % span
            let bump = (offset % 4) * max(span / 8, 1)
            let value = min(85, 15 + wave + bump)
            context.insert(PageRecordModel(
                id: UUID(),
                date: day,
                pageCount: value,
                createdAt: now,
                updatedAt: now
            ))
        }

        try? context.save()
        #endif
    }
}
#endif

import Foundation

struct PredictionResult: Sendable {
    let predictedCount: Int?
    let explanation: String
    let daysUsed: Int
}

protocol PredictPageUseCaseProtocol {
    func execute(records: [PageRecord], capacityResolver: (Date) async throws -> ShelfRecord?, currentShelf: Int) async throws -> PredictionResult
}

struct PredictPageUseCase: PredictPageUseCaseProtocol {
    func execute(records: [PageRecord], capacityResolver: (Date) async throws -> ShelfRecord?, currentShelf: Int) async throws -> PredictionResult {
        let sorted = records.sorted { $0.date > $1.date }
        let recentSeven = Array(sorted.prefix(7))

        var validDays: [(pages: Int, shelfs: Int)] = []
        for record in recentSeven {
            if let capacity = try await capacityResolver(record.date), capacity.shelfCount > 0 {
                validDays.append((pages: record.pageCount, shelfs: capacity.shelfCount))
            }
        }

        guard validDays.count >= 3 else {
            return PredictionResult(
                predictedCount: nil,
                explanation: "Not enough data (need at least 3 days, have \(validDays.count))",
                daysUsed: validDays.count
            )
        }

        let avgPagesPerShelf = validDays.reduce(0.0) { $0 + Double($1.pages) / Double($1.shelfs) } / Double(validDays.count)
        let raw = avgPagesPerShelf * Double(currentShelf)
        let clamped = max(0, min(Int(raw.rounded()), currentShelf * 50))

        return PredictionResult(
            predictedCount: clamped,
            explanation: "Based on last \(validDays.count) days",
            daysUsed: validDays.count
        )
    }
}

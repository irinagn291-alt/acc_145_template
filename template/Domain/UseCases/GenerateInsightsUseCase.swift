import Foundation

struct Insight: Sendable {
    let title: String
    let value: String
    let explanation: String
    let icon: String
}

protocol GenerateInsightsUseCaseProtocol {
    func execute(records: [PageRecord], currentShelf: Int?, capacityResolver: (Date) async throws -> ShelfRecord?) async throws -> [Insight]
}

struct GenerateInsightsUseCase: GenerateInsightsUseCaseProtocol {
    let calculatePagesPerShelf: CalculatePagesPerShelfUseCaseProtocol
    let calculateWeeklyAverage: CalculateWeeklyAverageUseCaseProtocol
    let getBestDay: GetBestDayUseCaseProtocol
    let predictPage: PredictPageUseCaseProtocol

    func execute(records: [PageRecord], currentShelf: Int?, capacityResolver: (Date) async throws -> ShelfRecord?) async throws -> [Insight] {
        var insights: [Insight] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        if let latestRecord = records.sorted(by: { $0.date > $1.date }).first,
           let capacity = try await capacityResolver(latestRecord.date),
           let fpb = calculatePagesPerShelf.execute(pageCount: latestRecord.pageCount, capacitySize: capacity.shelfCount) {
            insights.append(Insight(
                title: "Pages/Shelf",
                value: String(format: "%.1f", fpb),
                explanation: "Latest day: \(dateFormatter.string(from: latestRecord.date))",
                icon: "leaf"
            ))
        }

        if let avg = calculateWeeklyAverage.execute(records: records) {
            insights.append(Insight(
                title: "Weekly Average",
                value: String(format: "%.1f", avg),
                explanation: "Rolling average of last 7 recorded days",
                icon: "chart.line.uptrend.xyaxis"
            ))
        }

        if let best = getBestDay.execute(records: records) {
            insights.append(Insight(
                title: "Best Reading Day",
                value: "\(best.pageCount) pages",
                explanation: dateFormatter.string(from: best.date),
                icon: "trophy"
            ))
        }

        if let capacitySize = currentShelf, capacitySize > 0 {
            let prediction = try await predictPage.execute(
                records: records,
                capacityResolver: capacityResolver,
                currentShelf: capacitySize
            )
            if let count = prediction.predictedCount {
                insights.append(Insight(
                    title: "Tomorrow's Prediction",
                    value: "\(count) pages",
                    explanation: prediction.explanation,
                    icon: "sparkles"
                ))
            } else {
                insights.append(Insight(
                    title: "Tomorrow's Prediction",
                    value: "—",
                    explanation: prediction.explanation,
                    icon: "sparkles"
                ))
            }
        }

        return insights
    }
}

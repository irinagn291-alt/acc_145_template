import Foundation

protocol CalculateWeeklyAverageUseCaseProtocol {
    func execute(records: [PageRecord]) -> Double?
}

struct CalculateWeeklyAverageUseCase: CalculateWeeklyAverageUseCaseProtocol {
    func execute(records: [PageRecord]) -> Double? {
        let sorted = records.sorted { $0.date > $1.date }
        let recentSeven = Array(sorted.prefix(7))
        guard !recentSeven.isEmpty else { return nil }
        let total = recentSeven.reduce(0) { $0 + $1.pageCount }
        return Double(total) / Double(recentSeven.count)
    }
}

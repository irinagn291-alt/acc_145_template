import Foundation

enum ChartRange: String, CaseIterable, Identifiable {
    case week = "7d"
    case month = "30d"
    case quarter = "90d"
    case all = "All"

    var id: String { rawValue }

    var days: Int? {
        switch self {
        case .week: return 7
        case .month: return 30
        case .quarter: return 90
        case .all: return nil
        }
    }
}

struct DailyChartData: Identifiable {
    let id = UUID()
    let date: Date
    let pageCount: Int
}

struct WeeklyChartData: Identifiable {
    let id = UUID()
    let weekStart: Date
    let averageFlowers: Double
}

@MainActor
@Observable
final class ChartsViewModel {
    var selectedRange: ChartRange = .week
    var dailyData: [DailyChartData] = []
    var weeklyData: [WeeklyChartData] = []
    var showMovingAverage = false
    var movingAverageData: [DailyChartData] = []
    var isLoading = false

    private let getPageRecords: GetPageRecordsUseCaseProtocol

    init(getPageRecords: GetPageRecordsUseCaseProtocol) {
        self.getPageRecords = getPageRecords
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            var records = try await getPageRecords.execute()
            records.sort { $0.date < $1.date }

            if let days = selectedRange.days {
                let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
                records = records.filter { $0.date >= cutoff }
            }

            dailyData = records.map { DailyChartData(date: $0.date, pageCount: $0.pageCount) }
            buildWeeklyData(from: records)
            buildMovingAverage(from: records)
        } catch {}
    }

    private func buildWeeklyData(from records: [PageRecord]) {
        let calendar = Calendar.current
        var grouped: [Date: [Int]] = [:]
        for record in records {
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: record.date)
            if let weekStart = calendar.date(from: components) {
                grouped[weekStart, default: []].append(record.pageCount)
            }
        }
        weeklyData = grouped.map { key, values in
            WeeklyChartData(weekStart: key, averageFlowers: Double(values.reduce(0, +)) / Double(values.count))
        }.sorted { $0.weekStart < $1.weekStart }
    }

    private func buildMovingAverage(from records: [PageRecord]) {
        guard records.count >= 3 else {
            movingAverageData = []
            return
        }
        var result: [DailyChartData] = []
        for i in 2..<records.count {
            let window = records[max(0, i - 6)...i]
            let avg = window.reduce(0) { $0 + $1.pageCount } / window.count
            result.append(DailyChartData(date: records[i].date, pageCount: avg))
        }
        movingAverageData = result
    }
}

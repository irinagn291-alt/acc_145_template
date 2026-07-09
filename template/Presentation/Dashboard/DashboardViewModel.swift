import Foundation

@MainActor
@Observable
final class DashboardViewModel {
    var todayPageCount: Int?
    var currentShelf: Int?
    var todayPagesPerShelf: Double?
    var weeklyAverage: Double?
    var bestDay: PageRecord?
    var prediction: PredictionResult?
    var recentRecords: [(record: PageRecord, capacitySize: Int?, pagesPerShelf: String)] = []
    var hasData: Bool { todayPageCount != nil || !recentRecords.isEmpty }
    var hasShelfSetup: Bool { currentShelf != nil }
    var isLoading = false

    private let getPageRecords: GetPageRecordsUseCaseProtocol
    private let getCurrentShelfRecord: GetCurrentShelfRecordUseCaseProtocol
    private let getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol
    private let getPageRecordForDate: GetPageRecordForDateUseCaseProtocol
    private let calculatePagesPerShelf: CalculatePagesPerShelfUseCaseProtocol
    private let calculateWeeklyAverage: CalculateWeeklyAverageUseCaseProtocol
    private let getBestDay: GetBestDayUseCaseProtocol
    private let predictPage: PredictPageUseCaseProtocol

    init(
        getPageRecords: GetPageRecordsUseCaseProtocol,
        getCurrentShelfRecord: GetCurrentShelfRecordUseCaseProtocol,
        getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol,
        getPageRecordForDate: GetPageRecordForDateUseCaseProtocol,
        calculatePagesPerShelf: CalculatePagesPerShelfUseCaseProtocol,
        calculateWeeklyAverage: CalculateWeeklyAverageUseCaseProtocol,
        getBestDay: GetBestDayUseCaseProtocol,
        predictPage: PredictPageUseCaseProtocol
    ) {
        self.getPageRecords = getPageRecords
        self.getCurrentShelfRecord = getCurrentShelfRecord
        self.getShelfRecordForDate = getShelfRecordForDate
        self.getPageRecordForDate = getPageRecordForDate
        self.calculatePagesPerShelf = calculatePagesPerShelf
        self.calculateWeeklyAverage = calculateWeeklyAverage
        self.getBestDay = getBestDay
        self.predictPage = predictPage
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let allRecords = try await getPageRecords.execute()
            let capacityRecord = try await getCurrentShelfRecord.execute()
            currentShelf = capacityRecord?.shelfCount

            let todayRecord = try await getPageRecordForDate.execute(date: Date())
            todayPageCount = todayRecord?.pageCount

            if let today = todayRecord, let capacity = currentShelf {
                todayPagesPerShelf = calculatePagesPerShelf.execute(pageCount: today.pageCount, capacitySize: capacity)
            } else {
                todayPagesPerShelf = nil
            }

            weeklyAverage = calculateWeeklyAverage.execute(records: allRecords)
            bestDay = getBestDay.execute(records: allRecords)

            if let capacity = currentShelf, capacity > 0 {
                prediction = try await predictPage.execute(
                    records: allRecords,
                    capacityResolver: { [getShelfRecordForDate] date in
                        try await getShelfRecordForDate.execute(date: date)
                    },
                    currentShelf: capacity
                )
            }

            let recentFive = Array(allRecords.sorted { $0.date > $1.date }.prefix(5))
            var enriched: [(record: PageRecord, capacitySize: Int?, pagesPerShelf: String)] = []
            for record in recentFive {
                let capacity = try await getShelfRecordForDate.execute(date: record.date)
                let fpbStr: String
                if let g = capacity, g.shelfCount > 0 {
                    fpbStr = String(format: "%.1f", Double(record.pageCount) / Double(g.shelfCount))
                } else {
                    fpbStr = "N/A"
                }
                enriched.append((record: record, capacitySize: capacity?.shelfCount, pagesPerShelf: fpbStr))
            }
            recentRecords = enriched
        } catch {
        }
    }
}

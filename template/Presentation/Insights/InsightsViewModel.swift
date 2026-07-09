import Foundation

@MainActor
@Observable
final class InsightsViewModel {
    var insights: [Insight] = []
    var isLoading = false
    var hasData: Bool { !insights.isEmpty }

    private let generateInsights: GenerateInsightsUseCaseProtocol
    private let getPageRecords: GetPageRecordsUseCaseProtocol
    private let getCurrentShelfRecord: GetCurrentShelfRecordUseCaseProtocol
    private let getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol

    init(
        generateInsights: GenerateInsightsUseCaseProtocol,
        getPageRecords: GetPageRecordsUseCaseProtocol,
        getCurrentShelfRecord: GetCurrentShelfRecordUseCaseProtocol,
        getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol
    ) {
        self.generateInsights = generateInsights
        self.getPageRecords = getPageRecords
        self.getCurrentShelfRecord = getCurrentShelfRecord
        self.getShelfRecordForDate = getShelfRecordForDate
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let records = try await getPageRecords.execute()
            let capacity = try await getCurrentShelfRecord.execute()
            insights = try await generateInsights.execute(
                records: records,
                currentShelf: capacity?.shelfCount,
                capacityResolver: { [getShelfRecordForDate] date in
                    try await getShelfRecordForDate.execute(date: date)
                }
            )
        } catch {}
    }
}

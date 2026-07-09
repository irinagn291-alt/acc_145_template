import Foundation

@MainActor
@Observable
final class HistoryViewModel {
    var records: [(record: PageRecord, capacitySize: Int?, pagesPerShelf: String)] = []
    var filteredRecords: [(record: PageRecord, capacitySize: Int?, pagesPerShelf: String)] = []
    var searchText: String = ""
    var isLoading = false
    var showDeleteConfirmation = false
    var recordToDelete: PageRecord?

    private let getPageRecords: GetPageRecordsUseCaseProtocol
    private let getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol
    private let deletePageRecord: DeletePageRecordUseCaseProtocol
    private let hapticService: HapticService

    private let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    init(
        getPageRecords: GetPageRecordsUseCaseProtocol,
        getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol,
        deletePageRecord: DeletePageRecordUseCaseProtocol,
        hapticService: HapticService
    ) {
        self.getPageRecords = getPageRecords
        self.getShelfRecordForDate = getShelfRecordForDate
        self.deletePageRecord = deletePageRecord
        self.hapticService = hapticService
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let allRecords = try await getPageRecords.execute()
            let sorted = allRecords.sorted { $0.date > $1.date }
            var enriched: [(record: PageRecord, capacitySize: Int?, pagesPerShelf: String)] = []
            for record in sorted {
                let capacity = try await getShelfRecordForDate.execute(date: record.date)
                let fpbStr: String
                if let g = capacity, g.shelfCount > 0 {
                    fpbStr = String(format: "%.1f", Double(record.pageCount) / Double(g.shelfCount))
                } else {
                    fpbStr = "N/A"
                }
                enriched.append((record: record, capacitySize: capacity?.shelfCount, pagesPerShelf: fpbStr))
            }
            records = enriched
            applyFilter()
        } catch {}
    }

    func applyFilter() {
        if searchText.isEmpty {
            filteredRecords = records
        } else {
            filteredRecords = records.filter { item in
                monthFormatter.string(from: item.record.date).localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func confirmDelete(_ record: PageRecord) {
        recordToDelete = record
        showDeleteConfirmation = true
    }

    func deleteRecord() async {
        guard let record = recordToDelete else { return }
        do {
            try await deletePageRecord.execute(record)
            hapticService.success()
            recordToDelete = nil
            await loadData()
        } catch {
            hapticService.error()
        }
    }
}

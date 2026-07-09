import Foundation

@MainActor
@Observable
final class CalendarViewModel {
    var currentMonth: Date = DateNormalizer.startOfDay(Date())
    var selectedDate: Date?
    var bloomRecordsByDate: [Date: PageRecord] = [:]
    var selectedDayRecord: PageRecord?
    var selectedDayShelf: Int?
    var isLoading = false

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    var daysInMonth: [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        let weekdayOfFirst = calendar.component(.weekday, from: firstDay)
        let offset = (weekdayOfFirst - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }

    var weekdaySymbols: [String] {
        let calendar = Calendar.current
        let symbols = calendar.shortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday - 1
        return Array(symbols[firstWeekday...]) + Array(symbols[..<firstWeekday])
    }

    private let getPageRecords: GetPageRecordsUseCaseProtocol
    private let getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol

    init(
        getPageRecords: GetPageRecordsUseCaseProtocol,
        getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol
    ) {
        self.getPageRecords = getPageRecords
        self.getShelfRecordForDate = getShelfRecordForDate
    }

    func loadMonth() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let all = try await getPageRecords.execute()
            var dict: [Date: PageRecord] = [:]
            for record in all {
                dict[DateNormalizer.startOfDay(record.date)] = record
            }
            bloomRecordsByDate = dict
        } catch {}
    }

    func goToPreviousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
            selectedDate = nil
            selectedDayRecord = nil
        }
    }

    func goToNextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
            selectedDate = nil
            selectedDayRecord = nil
        }
    }

    func selectDate(_ date: Date) async {
        let normalized = DateNormalizer.startOfDay(date)
        selectedDate = normalized
        selectedDayRecord = bloomRecordsByDate[normalized]
        do {
            let capacity = try await getShelfRecordForDate.execute(date: normalized)
            selectedDayShelf = capacity?.shelfCount
        } catch {}
    }

    func yieldIntensity(for date: Date) -> Double {
        guard let record = bloomRecordsByDate[DateNormalizer.startOfDay(date)] else { return 0 }
        let maxExpected = 100.0
        return min(1.0, Double(record.pageCount) / maxExpected)
    }

    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

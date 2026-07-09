import SwiftUI

enum NavigationDestination: Hashable {
    case addPageRecord
    case editPageRecord(PageRecord)
    case shelfSettings
    case insights

    func hash(into hasher: inout Hasher) {
        switch self {
        case .addPageRecord: hasher.combine("add")
        case .editPageRecord(let r): hasher.combine("edit"); hasher.combine(r.id)
        case .shelfSettings: hasher.combine("setup")
        case .insights: hasher.combine("insights")
        }
    }

    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.addPageRecord, .addPageRecord): return true
        case (.editPageRecord(let a), .editPageRecord(let b)): return a.id == b.id
        case (.shelfSettings, .shelfSettings): return true
        case (.insights, .insights): return true
        default: return false
        }
    }
}

struct ContentView: View {
    var container: DIContainer
    @State private var page = 0
    @State private var path: [NavigationDestination] = []

    var body: some View {
        NavigationStack(path: $path) {
            TabView(selection: $page) {
                DashboardView(
                    viewModel: makeDashboardViewModel(),
                    onLogPages: { path.append(.addPageRecord) },
                    onUpdateShelf: { path.append(.shelfSettings) },
                    onViewInsights: { path.append(.insights) }
                ).tag(0)
                CalendarScreenView(viewModel: makeCalendarViewModel()).tag(1)
                ChartsView(viewModel: makeChartsViewModel()).tag(2)
                HistoryView(viewModel: makeHistoryViewModel(), onEditRecord: { path.append(.editPageRecord($0)) }).tag(3)
                SettingsView(viewModel: makeSettingsViewModel()).tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .navigationDestination(for: NavigationDestination.self) { dest in destinationView(for: dest) }
        }
        .tint(.inkNavy)
    }

    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .addPageRecord:
            AddPageRecordView(viewModel: makeAddViewModel(editing: nil))
        case .editPageRecord(let record):
            AddPageRecordView(viewModel: makeAddViewModel(editing: record))
        case .shelfSettings:
            ShelfSettingsView(viewModel: makeSetupViewModel())
        case .insights:
            InsightsView(viewModel: makeInsightsViewModel())
        }
    }


    private func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            getPageRecords: container.getPageRecords,
            getCurrentShelfRecord: container.getCurrentShelfRecord,
            getShelfRecordForDate: container.getShelfRecordForDate,
            getPageRecordForDate: container.getPageRecordForDate,
            calculatePagesPerShelf: container.calculatePagesPerShelf,
            calculateWeeklyAverage: container.calculateWeeklyAverage,
            getBestDay: container.getBestDay,
            predictPage: container.predictPage
        )
    }

    private func makeCalendarViewModel() -> CalendarViewModel {
        CalendarViewModel(
            getPageRecords: container.getPageRecords,
            getShelfRecordForDate: container.getShelfRecordForDate
        )
    }

    private func makeChartsViewModel() -> ChartsViewModel {
        ChartsViewModel(getPageRecords: container.getPageRecords)
    }

    private func makeHistoryViewModel() -> HistoryViewModel {
        HistoryViewModel(
            getPageRecords: container.getPageRecords,
            getShelfRecordForDate: container.getShelfRecordForDate,
            deletePageRecord: container.deletePageRecord,
            hapticService: container.hapticService
        )
    }

    private func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            exportCSV: container.exportCSV,
            getPageRecords: container.getPageRecords,
            getShelfRecordForDate: container.getShelfRecordForDate
        )
    }

    private func makeAddViewModel(editing: PageRecord?) -> AddPageRecordViewModel {
        AddPageRecordViewModel(
            addOrUpdatePageRecord: container.addOrUpdatePageRecord,
            getPageRecordForDate: container.getPageRecordForDate,
            getShelfRecordForDate: container.getShelfRecordForDate,
            deletePageRecord: container.deletePageRecord,
            hapticService: container.hapticService,
            editingRecord: editing
        )
    }

    private func makeSetupViewModel() -> ShelfSettingsViewModel {
        ShelfSettingsViewModel(
            getCurrentShelfRecord: container.getCurrentShelfRecord,
            addShelfRecord: container.addShelfRecord,
            deleteShelfRecord: container.deleteShelfRecord,
            shelfRepository: container.shelfRepository,
            hapticService: container.hapticService
        )
    }

    private func makeInsightsViewModel() -> InsightsViewModel {
        InsightsViewModel(
            generateInsights: container.generateInsights,
            getPageRecords: container.getPageRecords,
            getCurrentShelfRecord: container.getCurrentShelfRecord,
            getShelfRecordForDate: container.getShelfRecordForDate
        )
    }

}

import SwiftUI

struct CalendarScreenView: View {
    @Bindable var viewModel: CalendarViewModel
    private let df: DateFormatter = { let f = DateFormatter(); f.dateStyle = .medium; return f }()

    var body: some View {
        List {
            Section(viewModel.monthTitle) {
                ForEach(viewModel.daysInMonth.compactMap { $0 }, id: \.self) { date in
                    agendaRow(date)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.dynamicBackground.ignoresSafeArea())
        .navigationTitle("Reading Log")
        .toolbar { ToolbarItem(placement: .topBarTrailing) {
            HStack {
                Button { viewModel.goToPreviousMonth() } label: { Image(systemName: "chevron.left") }
                Button { viewModel.goToNextMonth() } label: { Image(systemName: "chevron.right") }
            }
        } }
        .task { await viewModel.loadMonth() }
    }
    private func agendaRow(_ date: Date) -> some View {
        let r = viewModel.bloomRecordsByDate[DateNormalizer.startOfDay(date)]
        return Button { Task { await viewModel.selectDate(date) } } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(df.string(from: date)).font(InkTypography.body())
                    Text(r.map { "\($0.pageCount) pages" } ?? "No reading").font(InkTypography.caption()).foregroundColor(Color.dynamicSecondaryText)
                }
                Spacer()
                if r != nil { Image(systemName: "book.fill").foregroundColor(.inkNavy) }
            }
        }
    }
}

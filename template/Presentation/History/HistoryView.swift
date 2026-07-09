import SwiftUI

struct HistoryView: View {
    @Bindable var viewModel: HistoryViewModel
    var onEditRecord: (PageRecord) -> Void
    private let dateFormatter: DateFormatter = { let f = DateFormatter(); f.dateStyle = .medium; return f }()
    private let monthFormatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "MMMM yyyy"; return f }()

    private func rowView(_ item: (record: PageRecord, capacitySize: Int?, pagesPerShelf: String)) -> some View {
        PageRecordRowView(date: dateFormatter.string(from: item.record.date), pageCount: item.record.pageCount,
            capacitySize: item.capacitySize, pagesPerShelf: item.pagesPerShelf)
    }


    private var grouped: [String: [(record: PageRecord, capacitySize: Int?, pagesPerShelf: String)]] {
        Dictionary(grouping: viewModel.filteredRecords) { monthFormatter.string(from: $0.record.date) }
    }
    private var groupedKeys: [String] { grouped.keys.sorted().reversed() }

    var body: some View {
        Group {
            if viewModel.isLoading { ProgressView().tint(.inkNavy).frame(maxWidth: .infinity, maxHeight: .infinity) }
            else if viewModel.records.isEmpty { EmptyStateView(iconName: "tray", message: "No pages logged yet. Start tracking your reading!", ctaTitle: "Log Pages", action: {}) }
            
            else {
                List {
                    ForEach(groupedKeys, id: \.self) { key in
                        Section(key) {
                            ForEach(grouped[key] ?? [], id: \.record.id) { item in
                                Button { onEditRecord(item.record) } label: { rowView(item) }
                                    .swipeActions { Button(role: .destructive) { viewModel.confirmDelete(item.record) } label: { Label("Delete", systemImage: "trash") } }
                            }
                        }
                    }
                }.listStyle(.insetGrouped).scrollContentBackground(.hidden)
            }

        }

        .background(Color.dynamicBackground.ignoresSafeArea())
        .navigationTitle("History")
        .searchable(text: $viewModel.searchText, prompt: "Filter by month")
        .task { await viewModel.loadData() }
        .onChange(of: viewModel.searchText) { _, _ in viewModel.applyFilter() }
        .alert("Delete Record", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) { Task { await viewModel.deleteRecord() } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("Delete this record?") }
    }
}


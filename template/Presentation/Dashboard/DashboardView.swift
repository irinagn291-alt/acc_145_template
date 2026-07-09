import SwiftUI

struct DashboardView: View {
    @Bindable var viewModel: DashboardViewModel
    var onLogPages: () -> Void
    var onUpdateShelf: () -> Void
    var onViewInsights: () -> Void
    private let dateFormatter: DateFormatter = { let f = DateFormatter(); f.dateStyle = .medium; return f }()

    private var emptyState: some View {
        Group {
            if !viewModel.hasShelfSetup && !viewModel.hasData {
                EmptyStateView(iconName: "book.fill", message: "Welcome to PageTurner! Set your bookshelf count to get started.", ctaTitle: "Set Shelves", action: onUpdateShelf)
            } else if !viewModel.hasData {
                EmptyStateView(iconName: "book.fill", message: "No pages logged yet. Start tracking your reading!", ctaTitle: "Log Pages", action: onLogPages)
            }
        }
    }

    private var recentBlock: some View {
        VStack(spacing: 8) {
            SectionHeaderView(title: "Recent")
            ForEach(viewModel.recentRecords, id: \.record.id) { item in
                PageRecordRowView(date: dateFormatter.string(from: item.record.date), pageCount: item.record.pageCount,
                    capacitySize: item.capacitySize, pagesPerShelf: item.pagesPerShelf).inkListRow()
            }
            if let best = viewModel.bestDay {
                SectionHeaderView(title: "Best Reading Day")
                HStack {
                    Text("\(best.pageCount) pages").font(InkTypography.header()).foregroundColor(.inkNavy)
                    Spacer()
                    Image(systemName: "trophy.fill").foregroundColor(.inkGold)
                }.inkCard().padding(.horizontal, 16)
            }
        }
    }
    private var actions: some View {
        HStack(spacing: 12) {
            Button(action: onLogPages) { Label("Log Pages", systemImage: "plus.circle.fill") }.buttonStyle(CompactButtonStyle())
            Button(action: onUpdateShelf) { Label("Shelf Setup", systemImage: "books.vertical.fill") }.buttonStyle(CompactButtonStyle())
            Button(action: onViewInsights) { Label("Insights", systemImage: "sparkles") }.buttonStyle(CompactButtonStyle())
        }.padding(.horizontal, 16)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.hasData {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Streak").font(InkTypography.caption())
                            Text("\(viewModel.recentRecords.count)d").font(InkTypography.largeNumber()).foregroundColor(.inkNavy)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Today's Reading").font(InkTypography.caption())
                            Text("\(viewModel.todayPageCount ?? 0)").font(InkTypography.largeNumber())
                        }
                    }.inkCard().padding(.horizontal, 16)
                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 4).fill(i < viewModel.recentRecords.count ? Color.inkNavy : Color.dynamicSecondaryText.opacity(0.2)).frame(height: 32)
                        }
                    }.padding(.horizontal, 16)
                    actions; recentBlock
                } else { emptyState }
            }.padding(.vertical, 16)
        }
        .background(Color.dynamicBackground.ignoresSafeArea())
        .navigationTitle("PageTurner")
        .task { await viewModel.loadData() }
    }
}

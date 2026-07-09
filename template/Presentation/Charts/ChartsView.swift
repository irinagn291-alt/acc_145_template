import SwiftUI
import Charts

struct ChartsView: View {
    @Bindable var viewModel: ChartsViewModel
    private var rangePicker: some View {
        VStack(spacing: 12) {
            Picker("Range", selection: $viewModel.selectedRange) {
                ForEach(ChartRange.allCases) { Text($0.rawValue).tag($0) }
            }.pickerStyle(.segmented).padding(.horizontal, 16)
            Toggle("Moving Average", isOn: $viewModel.showMovingAverage).tint(.inkNavy).padding(.horizontal, 16)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                rangePicker
                SectionHeaderView(title: "Daily Pages").padding(.horizontal, 16)
                if viewModel.dailyData.isEmpty {
                    Text("No data").font(InkTypography.caption()).padding(40)
                } else {
                    
            Chart { ForEach(viewModel.weeklyData) { item in
                BarMark(x: .value("Avg", item.averageFlowers), y: .value("Week", item.weekStart, unit: .weekOfYear))
                    .foregroundStyle(Color.inkNavy).cornerRadius(4)
            } }.frame(height: 260).padding(.horizontal, 16)

                }
                
            }.padding(.vertical, 16)
        }

        .background(Color.dynamicBackground.ignoresSafeArea())
        .navigationTitle("Charts")
        .task { await viewModel.loadData() }
        .onChange(of: viewModel.selectedRange) { _, _ in Task { await viewModel.loadData() } }
    }
}


import SwiftUI

struct InsightsView: View {
    @Bindable var viewModel: InsightsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.inkNavy)
                        .padding(.top, 40)
                } else if !viewModel.hasData {
                    EmptyStateView(
                        iconName: "sparkles",
                        message: "Not enough data for insights yet. Keep logging your pages!",
                        ctaTitle: "Go Back",
                        action: {}
                    )
                } else {
                    GradientHeroHeader(
                        title: "Insights",
                        subtitle: "Your pageturner performance at a glance"
                    )

                    ForEach(Array(viewModel.insights.enumerated()), id: \.offset) { _, insight in
                        InsightCardView(
                            title: insight.title,
                            value: insight.value,
                            explanation: insight.explanation,
                            icon: insight.icon
                        )
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color.dynamicBackground.ignoresSafeArea())
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadData() }
    }
}

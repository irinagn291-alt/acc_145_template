import SwiftUI

struct EmptyStateView: View {
    let iconName: String
    let message: String
    let ctaTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: iconName)
                .font(.system(size: 64))
                .foregroundStyle(LinearGradient.inkGradient)
            Text(message)
                .font(InkTypography.header())
                .foregroundColor(Color.dynamicText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button(action: action) { Text(ctaTitle) }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dynamicBackground.ignoresSafeArea())
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentColor)
                Spacer()
            }
            Text(value)
                .font(InkTypography.largeNumber())
                .foregroundColor(Color.dynamicText)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(title)
                .font(InkTypography.caption())
                .foregroundColor(Color.dynamicSecondaryText)
        }
        .inkCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

struct InsightCardView: View {
    let title: String
    let value: String
    let explanation: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(LinearGradient.inkGradient)
                    .font(.system(size: 20))
                Text(title)
                    .font(InkTypography.header())
                    .foregroundColor(Color.dynamicText)
                Spacer()
            }
            Text(value)
                .font(InkTypography.largeNumber())
                .foregroundColor(.inkNavy)
            Text(explanation)
                .font(InkTypography.caption())
                .foregroundColor(Color.dynamicSecondaryText)
        }
        .inkCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value). \(explanation)")
    }
}

struct SectionHeaderView: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionLabel: String? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(InkTypography.header())
                .foregroundColor(Color.dynamicText)
            Spacer()
            if let action, let actionLabel {
                Button(action: action) {
                    Text(actionLabel)
                        .font(InkTypography.caption())
                        .foregroundColor(.inkNavy)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct GradientHeroHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(InkTypography.title())
                .foregroundColor(.white)
            Text(subtitle)
                .font(InkTypography.body())
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(LinearGradient.inkGradient)
        .cornerRadius(24)
        .padding(.horizontal, 16)
    }
}

struct ValidationMessageView: View {
    let message: String
    let isError: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "info.circle.fill")
                .font(.system(size: 14))
            Text(message)
                .font(InkTypography.caption())
        }
        .foregroundColor(isError ? .red : .inkNavy)
        .padding(.horizontal, 4)
    }
}

struct PageRecordRowView: View {
    let date: String
    let pageCount: Int
    let capacitySize: Int?
    let pagesPerShelf: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(date)
                    .font(InkTypography.body())
                    .foregroundColor(Color.dynamicText)
                Text(capacitySize.map { "Shelve: \($0) shelves" } ?? "Shelve: N/A")
                    .font(InkTypography.caption())
                    .foregroundColor(Color.dynamicSecondaryText)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Text("\(pageCount)")
                        .font(InkTypography.header())
                        .foregroundColor(.inkNavy)
                    Image(systemName: "book.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.inkGold)
                }
                Text("\(pagesPerShelf)/shelve")
                    .font(InkTypography.caption())
                    .foregroundColor(Color.dynamicSecondaryText)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(date), \(pageCount) pages, \(pagesPerShelf) per shelve")
    }
}

struct ShelfRecordHistoryRowView: View {
    let effectiveDate: String
    let shelfCount: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Effective: \(effectiveDate)")
                    .font(InkTypography.body())
                    .foregroundColor(Color.dynamicText)
            }
            Spacer()
            HStack(spacing: 4) {
                Text("\(shelfCount)")
                    .font(InkTypography.header())
                    .foregroundColor(.inkNavy)
                Image(systemName: "books.vertical.fill")
                    .foregroundColor(.inkGold)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Garden size \(shelfCount) shelves, effective \(effectiveDate)")
    }
}

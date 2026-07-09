import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                appearanceSection
                hapticsSection
                dataSection
                aboutSection
            }
            .padding(.vertical, 16)
        }
        .background(Color.dynamicBackground.ignoresSafeArea())
        .navigationTitle("Settings")
        .sheet(isPresented: $viewModel.showPrivacyPolicy) {
            NavigationStack {
                PrivacyPolicyView()
            }
        }
        .sheet(isPresented: $viewModel.showContactUs) {
            NavigationStack {
                ContactUsWebView()
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let csv = viewModel.exportedCSV {
                ShareSheet(items: [csv])
            }
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Appearance")
            Picker("Appearance", selection: $viewModel.appearanceMode) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
        }
    }

    private var hapticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $viewModel.hapticsEnabled) {
                HStack {
                    Image(systemName: "hand.tap.fill")
                        .foregroundColor(.inkNavy)
                    Text("Haptic Feedback")
                        .font(InkTypography.body())
                        .foregroundColor(Color.dynamicText)
                }
            }
            .tint(.inkNavy)
            .padding(.horizontal, 16)
        }
        .inkCard()
        .padding(.horizontal, 16)
    }

    private var dataSection: some View {
        VStack(spacing: 12) {
            SectionHeaderView(title: "Data")

            Button {
                Task { await viewModel.exportData() }
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.inkNavy)
                    Text("Export CSV")
                        .font(InkTypography.body())
                        .foregroundColor(Color.dynamicText)
                    Spacer()
                    if viewModel.isExporting {
                        ProgressView()
                            .tint(.inkNavy)
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.dynamicSecondaryText)
                    }
                }
            }
            .inkCard()
            .padding(.horizontal, 16)

            Button {
                viewModel.showContactUs = true
            } label: {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.inkNavy)
                    Text("Contact Us")
                        .font(InkTypography.body())
                        .foregroundColor(Color.dynamicText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.dynamicSecondaryText)
                }
            }
            .inkCard()
            .padding(.horizontal, 16)

            Button {
                viewModel.showPrivacyPolicy = true
            } label: {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.inkNavy)
                    Text("Privacy Policy")
                        .font(InkTypography.body())
                        .foregroundColor(Color.dynamicText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.dynamicSecondaryText)
                }
            }
            .inkCard()
            .padding(.horizontal, 16)
        }
    }

    private var aboutSection: some View {
        VStack(spacing: 8) {
            SectionHeaderView(title: "About")

            VStack(spacing: 8) {
                Image(systemName: "book.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(LinearGradient.inkGradient)
                Text("PageTurner")
                    .font(InkTypography.title())
                    .foregroundColor(Color.dynamicText)
                Text("Version \(viewModel.appVersion)")
                    .font(InkTypography.caption())
                    .foregroundColor(Color.dynamicSecondaryText)
            }
            .frame(maxWidth: .infinity)
            .inkCard()
            .padding(.horizontal, 16)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

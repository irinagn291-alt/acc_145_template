import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            Text(privacyPolicyText)
                .font(InkTypography.body())
                .foregroundColor(Color.dynamicText)
                .padding(20)
        }
        .background(Color.dynamicBackground.ignoresSafeArea())
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
                    .foregroundColor(.inkNavy)
            }
        }
    }

    private let privacyPolicyText = """
    PageTurner Privacy Policy

    Last updated: 2025

    PageTurner ("the App") is developed and maintained independently. Your privacy is important to us. This policy explains how the App handles your information.

    Data Collection and Storage
    PageTurner does not collect, transmit, or share any personal data. All data you enter into the App — including pages records, shelf setup history, and app preferences — is stored exclusively on your device using Apple's local storage frameworks. No data is sent to any server, cloud service, or third party.

    No Analytics or Tracking
    PageTurner does not use any analytics services, advertising frameworks, tracking pixels, or third-party SDKs. The App does not track your location, browsing behavior, or usage patterns.

    No Account Required
    PageTurner does not require you to create an account, provide an email address, or share any identifying information.

    Data Export
    The App provides a CSV export feature that allows you to export your bloom data. This export is initiated solely by you and is shared using your device's native sharing capabilities. The developer has no access to exported files.

    Data Deletion
    Since all data is stored locally on your device, you can delete all App data at any time by deleting the App from your device.

    Children's Privacy
    PageTurner does not knowingly collect information from children. The App contains no age-restricted content.

    Changes to This Policy
    We may update this privacy policy from time to time. Any changes will be reflected within the App.

    Contact
    If you have questions about this privacy policy, please visit our Contact Us page within the App.
    """
}

import SwiftUI
import Alamofire

struct ContactUsWebView: View {
    @Environment(\.dismiss) private var dismiss

    private var contactURL: String {
        AppConfiguration.serverBaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/contact-us"
    }

    var body: some View {
        Alamofire.WebContentView(url: contactURL)
            .navigationTitle("Contact Us")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.inkNavy)
                }
            }
    }
}

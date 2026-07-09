import Foundation
import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }
}

@MainActor
@Observable
final class SettingsViewModel {
    var appearanceMode: AppearanceMode {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode") }
    }
    var hapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: "hapticsEnabled") }
    }

    var showPrivacyPolicy = false
    var showContactUs = false
    var isExporting = false
    var exportedCSV: String?
    var showShareSheet = false

    private let exportCSV: ExportCSVUseCaseProtocol
    private let getPageRecords: GetPageRecordsUseCaseProtocol
    private let getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol

    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

    init(
        exportCSV: ExportCSVUseCaseProtocol,
        getPageRecords: GetPageRecordsUseCaseProtocol,
        getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol
    ) {
        self.exportCSV = exportCSV
        self.getPageRecords = getPageRecords
        self.getShelfRecordForDate = getShelfRecordForDate
        self.appearanceMode = AppearanceMode(rawValue: UserDefaults.standard.string(forKey: "appearanceMode") ?? "System") ?? .system
        self.hapticsEnabled = UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
    }

    func exportData() async {
        isExporting = true
        defer { isExporting = false }

        do {
            let records = try await getPageRecords.execute()
            let csv = try await exportCSV.execute(
                records: records,
                capacityResolver: { [getShelfRecordForDate] date in
                    try await getShelfRecordForDate.execute(date: date)
                }
            )
            exportedCSV = csv
            showShareSheet = true
        } catch {}
    }
}

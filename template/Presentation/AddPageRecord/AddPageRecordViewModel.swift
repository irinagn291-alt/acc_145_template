import Foundation

@MainActor
@Observable
final class AddPageRecordViewModel {
    var selectedDate: Date = DateNormalizer.startOfDay(Date())
    var pageCountText: String = ""
    var pageCount: Int { Int(pageCountText) ?? 0 }
    var isEditing: Bool { existingRecord != nil }
    var existingRecord: PageRecord?
    var capacityForDate: Int?
    var validationMessage: String?
    var isValidationError = false
    var isSaving = false
    var saveSucceeded = false
    var showDeleteConfirmation = false

    var canSave: Bool {
        guard !isSaving else { return false }
        guard pageCount >= 0, !pageCountText.isEmpty else { return false }
        guard selectedDate <= DateNormalizer.startOfDay(Date()) else { return false }
        guard let capacity = capacityForDate, capacity > 0 else { return false }
        guard pageCount <= capacity * 50 else { return false }
        return true
    }

    var maxPageCount: Int { (capacityForDate ?? 0) * 50 }

    private let addOrUpdatePageRecord: AddOrUpdatePageRecordUseCaseProtocol
    private let getPageRecordForDate: GetPageRecordForDateUseCaseProtocol
    private let getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol
    private let deletePageRecord: DeletePageRecordUseCaseProtocol
    private let hapticService: HapticService

    init(
        addOrUpdatePageRecord: AddOrUpdatePageRecordUseCaseProtocol,
        getPageRecordForDate: GetPageRecordForDateUseCaseProtocol,
        getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol,
        deletePageRecord: DeletePageRecordUseCaseProtocol,
        hapticService: HapticService,
        editingRecord: PageRecord? = nil
    ) {
        self.addOrUpdatePageRecord = addOrUpdatePageRecord
        self.getPageRecordForDate = getPageRecordForDate
        self.getShelfRecordForDate = getShelfRecordForDate
        self.deletePageRecord = deletePageRecord
        self.hapticService = hapticService

        if let record = editingRecord {
            self.existingRecord = record
            self.selectedDate = record.date
            self.pageCountText = "\(record.pageCount)"
        }
    }

    func onDateChanged() async {
        let normalized = DateNormalizer.startOfDay(selectedDate)
        do {
            let capacity = try await getShelfRecordForDate.execute(date: normalized)
            capacityForDate = capacity?.shelfCount

            if capacityForDate == nil {
                validationMessage = "No shelf setup for this date. Please configure it first."
                isValidationError = true
            } else {
                validationMessage = nil
                isValidationError = false
            }

            let existing = try await getPageRecordForDate.execute(date: normalized)
            if existing?.id != existingRecord?.id {
                existingRecord = existing
                if let e = existing {
                    pageCountText = "\(e.pageCount)"
                }
            }
        } catch {}

        validate()
    }

    func validate() {
        let today = DateNormalizer.startOfDay(Date())
        if selectedDate > today {
            validationMessage = "Cannot log entries for a future date"
            isValidationError = true
            return
        }
        if let count = Int(pageCountText), count < 0 {
            validationMessage = "Pages count cannot be negative"
            isValidationError = true
            return
        }
        if capacityForDate == nil {
            validationMessage = "No shelf setup set for this date"
            isValidationError = true
            return
        }
        if let capacity = capacityForDate, pageCount > capacity * 50 {
            validationMessage = "Pages count cannot exceed \(capacity * 50) (shelves × 50)"
            isValidationError = true
            return
        }
        validationMessage = nil
        isValidationError = false
    }

    func save() async {
        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await addOrUpdatePageRecord.execute(date: selectedDate, pageCount: pageCount)
            hapticService.success()
            saveSucceeded = true
        } catch let error as PageTurnerError {
            validationMessage = error.errorDescription
            isValidationError = true
            hapticService.error()
        } catch {
            validationMessage = "Failed to save"
            isValidationError = true
            hapticService.error()
        }
    }

    func deleteRecord() async {
        guard let record = existingRecord else { return }
        do {
            try await deletePageRecord.execute(record)
            hapticService.success()
            saveSucceeded = true
        } catch {
            validationMessage = "Failed to delete"
            isValidationError = true
        }
    }
}

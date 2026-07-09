import Foundation

@MainActor
@Observable
final class ShelfSettingsViewModel {
    var currentShelf: Int?
    var capacityHistory: [ShelfRecord] = []
    var newShelfCount: String = ""
    var newEffectiveDate: Date = DateNormalizer.startOfDay(Date())
    var isLoading = false
    var isSaving = false
    var saveSucceeded = false
    var errorMessage: String?
    var showDeleteAlert = false
    var recordToDelete: ShelfRecord?
    var deleteErrorMessage: String?
    var showDeleteError = false

    var canSave: Bool {
        guard let count = Int(newShelfCount), count > 0 else { return false }
        return !isSaving
    }

    private let getCurrentShelfRecord: GetCurrentShelfRecordUseCaseProtocol
    private let addShelfRecord: AddShelfRecordUseCaseProtocol
    private let deleteShelfRecord: DeleteShelfRecordUseCaseProtocol
    private let shelfRepository: ShelfRecordRepositoryProtocol
    private let hapticService: HapticService

    init(
        getCurrentShelfRecord: GetCurrentShelfRecordUseCaseProtocol,
        addShelfRecord: AddShelfRecordUseCaseProtocol,
        deleteShelfRecord: DeleteShelfRecordUseCaseProtocol,
        shelfRepository: ShelfRecordRepositoryProtocol,
        hapticService: HapticService
    ) {
        self.getCurrentShelfRecord = getCurrentShelfRecord
        self.addShelfRecord = addShelfRecord
        self.deleteShelfRecord = deleteShelfRecord
        self.shelfRepository = shelfRepository
        self.hapticService = hapticService
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let current = try await getCurrentShelfRecord.execute()
            currentShelf = current?.shelfCount
            capacityHistory = try await shelfRepository.fetchAll()
        } catch {}
    }

    func save() async {
        isSaving = true
        defer { isSaving = false }

        guard let count = Int(newShelfCount), count > 0 else {
            errorMessage = "Shelve count must be greater than zero"
            return
        }

        do {
            _ = try await addShelfRecord.execute(effectiveDate: newEffectiveDate, shelfCount: count)
            hapticService.success()
            newShelfCount = ""
            newEffectiveDate = DateNormalizer.startOfDay(Date())
            errorMessage = nil
            await loadData()
        } catch let error as PageTurnerError {
            errorMessage = error.errorDescription
            hapticService.error()
        } catch {
            errorMessage = "Failed to save"
            hapticService.error()
        }
    }

    func confirmDelete(_ record: ShelfRecord) {
        recordToDelete = record
        showDeleteAlert = true
    }

    func deleteRecord() async {
        guard let record = recordToDelete else { return }
        do {
            try await deleteShelfRecord.execute(record, allCapacityRecords: capacityHistory)
            hapticService.success()
            recordToDelete = nil
            await loadData()
        } catch let error as PageTurnerError {
            deleteErrorMessage = error.errorDescription
            showDeleteError = true
            hapticService.error()
        } catch {
            deleteErrorMessage = "Failed to delete"
            showDeleteError = true
            hapticService.error()
        }
    }
}

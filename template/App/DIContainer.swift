import Foundation
import SwiftData

@MainActor
@Observable
final class DIContainer {
    let modelContainer: ModelContainer
    let modelContext: ModelContext

    let pageRepository: PageRecordRepositoryProtocol
    let shelfRepository: ShelfRecordRepositoryProtocol

    let addOrUpdatePageRecord: AddOrUpdatePageRecordUseCaseProtocol
    let deletePageRecord: DeletePageRecordUseCaseProtocol
    let getPageRecords: GetPageRecordsUseCaseProtocol
    let getPageRecordForDate: GetPageRecordForDateUseCaseProtocol
    let addShelfRecord: AddShelfRecordUseCaseProtocol
    let deleteShelfRecord: DeleteShelfRecordUseCaseProtocol
    let getShelfRecordForDate: GetShelfRecordForDateUseCaseProtocol
    let getCurrentShelfRecord: GetCurrentShelfRecordUseCaseProtocol
    let calculatePagesPerShelf: CalculatePagesPerShelfUseCaseProtocol
    let calculateWeeklyAverage: CalculateWeeklyAverageUseCaseProtocol
    let getBestDay: GetBestDayUseCaseProtocol
    let predictPage: PredictPageUseCaseProtocol
    let generateInsights: GenerateInsightsUseCaseProtocol
    let exportCSV: ExportCSVUseCaseProtocol

    let hapticService: HapticService

    init() throws {
        let container = try ModelContainerSetup.create()
        self.modelContainer = container
        self.modelContext = container.mainContext

        let primaryRepo = SwiftDataPageRecordRepository(modelContext: modelContext)
        let capacityRepo = SwiftDataShelfRecordRepository(modelContext: modelContext)
        self.pageRepository = primaryRepo
        self.shelfRepository = capacityRepo

        self.addOrUpdatePageRecord = AddOrUpdatePageRecordUseCase(
            pageRepository: primaryRepo,
            shelfRepository: capacityRepo
        )
        self.deletePageRecord = DeletePageRecordUseCase(pageRepository: primaryRepo)
        self.getPageRecords = GetPageRecordsUseCase(pageRepository: primaryRepo)
        self.getPageRecordForDate = GetPageRecordForDateUseCase(pageRepository: primaryRepo)
        self.addShelfRecord = AddShelfRecordUseCase(shelfRepository: capacityRepo)
        self.deleteShelfRecord = DeleteShelfRecordUseCase(shelfRepository: capacityRepo)
        self.getShelfRecordForDate = GetShelfRecordForDateUseCase(shelfRepository: capacityRepo)
        self.getCurrentShelfRecord = GetCurrentShelfRecordUseCase(shelfRepository: capacityRepo)
        self.calculatePagesPerShelf = CalculatePagesPerShelfUseCase()
        self.calculateWeeklyAverage = CalculateWeeklyAverageUseCase()
        self.getBestDay = GetBestDayUseCase()
        self.predictPage = PredictPageUseCase()
        self.generateInsights = GenerateInsightsUseCase(
            calculatePagesPerShelf: CalculatePagesPerShelfUseCase(),
            calculateWeeklyAverage: CalculateWeeklyAverageUseCase(),
            getBestDay: GetBestDayUseCase(),
            predictPage: PredictPageUseCase()
        )
        self.exportCSV = ExportCSVUseCase()
        self.hapticService = HapticService()

        #if DEBUG
        MockDataSeeder.seedIfNeeded(context: modelContext)
        #endif
    }
}

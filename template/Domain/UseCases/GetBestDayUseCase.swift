import Foundation

protocol GetBestDayUseCaseProtocol {
    func execute(records: [PageRecord]) -> PageRecord?
}

struct GetBestDayUseCase: GetBestDayUseCaseProtocol {
    func execute(records: [PageRecord]) -> PageRecord? {
        guard !records.isEmpty else { return nil }
        return records.max { lhs, rhs in
            if lhs.pageCount == rhs.pageCount {
                return lhs.date < rhs.date
            }
            return lhs.pageCount < rhs.pageCount
        }
    }
}

import Foundation

enum PageTurnerError: LocalizedError {
    case futureDateNotAllowed
    case negativePageCount
    case noShelfForDate
    case pageCountExceedsMax(max: Int)
    case invalidShelf
    case recordNotFound
    case deletionWouldOrphanRecords

    var errorDescription: String? {
        switch self {
        case .futureDateNotAllowed:
            return "Cannot log entries for a future date"
        case .negativePageCount:
            return "Pages count cannot be negative"
        case .noShelfForDate:
            return "No shelf setup for this date. Please configure it first."
        case .pageCountExceedsMax(let max):
            return "Pages count cannot exceed \(max) (shelves × 50)"
        case .invalidShelf:
            return "Shelve count must be greater than zero"
        case .recordNotFound:
            return "Record not found"
        case .deletionWouldOrphanRecords:
            return "Cannot delete this record because dependent entries exist"
        }
    }
}

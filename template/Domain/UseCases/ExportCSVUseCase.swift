import Foundation

protocol ExportCSVUseCaseProtocol {
    func execute(records: [PageRecord], capacityResolver: (Date) async throws -> ShelfRecord?) async throws -> String
}

struct ExportCSVUseCase: ExportCSVUseCaseProtocol {
    func execute(records: [PageRecord], capacityResolver: (Date) async throws -> ShelfRecord?) async throws -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var csv = "Date,Pages,Shelves,pages/shelf\n"
        let sorted = records.sorted { $0.date < $1.date }

        for record in sorted {
            let dateStr = dateFormatter.string(from: record.date)
            let capacity = try await capacityResolver(record.date)
            let capacityStr = capacity.map { "\($0.shelfCount)" } ?? "N/A"
            let fpbStr: String
            if let g = capacity, g.shelfCount > 0 {
                fpbStr = String(format: "%.2f", Double(record.pageCount) / Double(g.shelfCount))
            } else {
                fpbStr = "N/A"
            }
            csv += "\(dateStr),\(record.pageCount),\(capacityStr),\(fpbStr)\n"
        }

        return csv
    }
}

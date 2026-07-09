import Foundation

protocol CalculatePagesPerShelfUseCaseProtocol {
    func execute(pageCount: Int, capacitySize: Int) -> Double?
}

struct CalculatePagesPerShelfUseCase: CalculatePagesPerShelfUseCaseProtocol {
    func execute(pageCount: Int, capacitySize: Int) -> Double? {
        guard capacitySize > 0 else { return nil }
        return Double(pageCount) / Double(capacitySize)
    }
}

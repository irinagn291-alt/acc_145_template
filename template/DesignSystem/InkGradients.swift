import SwiftUI

extension LinearGradient {
    static let inkGradient = LinearGradient(
        colors: [.inkNavy, .inkSlate, .inkParchment],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let inkSubtleGradient = LinearGradient(
        colors: [.inkNavy.opacity(0.15), .inkParchment.opacity(0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

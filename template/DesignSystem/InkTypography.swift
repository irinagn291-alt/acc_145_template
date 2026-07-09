import SwiftUI

struct InkTypography {
    static func title() -> Font { .system(size: 28, weight: .bold, design: .serif) }
    static func header() -> Font { .system(size: 22, weight: .semibold, design: .serif) }
    static func body() -> Font { .system(size: 16, weight: .regular, design: .serif) }
    static func caption() -> Font { .system(size: 14, weight: .medium, design: .serif) }
    static func largeNumber() -> Font { .system(size: 40, weight: .bold, design: .serif) }
    static func smallLabel() -> Font { .system(size: 12, weight: .regular, design: .serif) }
}

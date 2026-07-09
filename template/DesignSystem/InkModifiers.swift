import SwiftUI

struct InkCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(20).background(Color.dynamicSurface)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .shadow(color: Color.inkNavy.opacity(0.08), radius: 8, y: 4)
    }
}
struct InkListRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(.vertical, 12).padding(.horizontal, 16)
            .background(Color.dynamicSurface).clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16).padding(.vertical, 4)
    }
}
extension View {
    func inkCard() -> some View { modifier(InkCardModifier()) }
    func inkListRow() -> some View { modifier(InkListRowModifier()) }
}

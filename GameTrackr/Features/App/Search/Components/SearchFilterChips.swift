import SwiftUI

struct SearchFilterChips: View {
    let platforms: [GamePlatform]
    @Binding var selection: GamePlatform?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                chip(title: "All", isSelected: selection == nil) { selection = nil }

                ForEach(platforms) { platform in
                    chip(title: platform.label, isSelected: selection == platform) {
                        selection = platform
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.appLabel(14))
                .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextPrimary)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(Capsule().fill(isSelected ? Color.appPrimary : Color.clear))
                .overlay(Capsule().stroke(isSelected ? Color.clear : Color.appOutline, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    @Previewable @State var selection: GamePlatform?
    SearchFilterChips(
        platforms: [
            GamePlatform(id: 6, slug: "win", name: "PC (Microsoft Windows)"),
            GamePlatform(id: 167, slug: "ps5", name: "PlayStation 5"),
            GamePlatform(id: 169, slug: "series-x-s", name: "Xbox Series X|S")
        ],
        selection: $selection
    )
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

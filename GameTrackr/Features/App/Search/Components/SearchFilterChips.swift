import SwiftUI

private enum Constants {
    static let labelSize: CGFloat = 14
    static let borderWidth: CGFloat = 1
}

struct SearchFilterChips: View {
    let platforms: [GamePlatform]
    let selection: GamePlatform?
    var onSelect: (GamePlatform?) -> Void = { _ in }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                chip(title: "All", isSelected: selection == nil) { onSelect(nil) }

                ForEach(platforms) { platform in
                    chip(title: platform.label, isSelected: selection == platform) {
                        onSelect(platform)
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.appLabel(Constants.labelSize))
                .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(Capsule().fill(isSelected ? Color.appPrimary : Color.clear))
                .overlay(Capsule().stroke(
                    isSelected ? Color.clear : Color.appOutline,
                    lineWidth: Constants.borderWidth
                ))
                .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    SearchFilterChips(platforms: HomeMockData.platforms, selection: nil)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

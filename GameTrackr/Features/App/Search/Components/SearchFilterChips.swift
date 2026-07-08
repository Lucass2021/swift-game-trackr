import SwiftUI

struct SearchFilterChips: View {
    @Binding var selection: GamePlatform?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                chip(title: "All", isSelected: selection == nil) { selection = nil }

                ForEach(GamePlatform.allCases) { platform in
                    chip(title: platform.rawValue, isSelected: selection == platform) {
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
    SearchFilterChips(selection: $selection)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

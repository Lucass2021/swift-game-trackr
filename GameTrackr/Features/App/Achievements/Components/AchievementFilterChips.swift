import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let labelSize: CGFloat = 14
}

struct AchievementFilterChips: View {
    let selection: AchievementFilter
    let onSelect: (AchievementFilter) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(AchievementFilter.allCases) { filter in
                    chip(filter)
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    private func chip(_ filter: AchievementFilter) -> some View {
        let isSelected = filter == selection

        return Button {
            onSelect(filter)
        } label: {
            Text(filter.title)
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
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    AchievementFilterChips(selection: .inProgress, onSelect: { _ in })
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let labelSize: CGFloat = 14
}

struct NotificationFilterTabs: View {
    let selection: NotificationFilter
    let onSelect: (NotificationFilter) -> Void

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(NotificationFilter.allCases) { filter in
                chip(filter)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Spacing.lg)
    }

    private func chip(_ filter: NotificationFilter) -> some View {
        let isSelected = selection == filter
        return Button {
            onSelect(filter)
        } label: {
            Text(filter.rawValue)
                .font(.appLabel(Constants.labelSize))
                .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.appPrimary : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.appOutline, lineWidth: Constants.borderWidth)
                )
                .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    NotificationFilterTabs(selection: .all, onSelect: { _ in })
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

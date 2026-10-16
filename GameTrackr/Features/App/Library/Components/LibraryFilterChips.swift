import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let labelSize: CGFloat = 14
}

struct LibraryFilterChips: View {
    let selection: LibraryStatus?
    let onSelect: (LibraryStatus?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                chip(title: "All", isSelected: selection == nil) { onSelect(nil) }

                ForEach(LibraryStatus.allCases) { status in
                    chip(title: status.rawValue, isSelected: selection == status) {
                        onSelect(status)
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
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    LibraryFilterChips(selection: .playing, onSelect: { _ in })
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

import SwiftUI

private enum Constants {
    static let labelSize: CGFloat = 14
    static let borderWidth: CGFloat = 1
}

struct CommunityChipRow: View {
    let titles: [String]
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(titles, id: \.self) { title in
                    chip(title)
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    private func chip(_ title: String) -> some View {
        let isSelected = selection == title
        return Button {
            selection = title
        } label: {
            Text(title)
                .font(.appLabel(Constants.labelSize))
                .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(Capsule().fill(isSelected ? Color.appPrimary : Color.clear))
                .overlay(
                    Capsule().stroke(isSelected ? Color.clear : Color.appOutline, lineWidth: Constants.borderWidth)
                )
                .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    @Previewable @State var selection = "All"
    CommunityChipRow(titles: CommunityOptions.categories, selection: $selection)
        .padding(.vertical)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

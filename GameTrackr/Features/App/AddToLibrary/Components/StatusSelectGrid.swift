import SwiftUI

private enum Constants {
    static let chipHeight: CGFloat = 64
    static let textSize: CGFloat = 14
    static let borderWidth: CGFloat = 1
    static let columns = 3
    static let glowAlpha = 0.4
    static let glowRadius: CGFloat = 14
    static let glowY: CGFloat = 2
}

struct StatusSelectGrid: View {
    @Binding var selection: LibraryStatus

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.xs), count: Constants.columns)

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.xs) {
            ForEach(LibraryStatus.allCases) { status in
                let isSelected = status == selection
                Button {
                    selection = status
                } label: {
                    Text(status.rawValue)
                        .font(.appLabel(Constants.textSize))
                        .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.chipHeight)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                .fill(isSelected ? Color.appPrimary : Color.appSurfaceCard)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                .stroke(isSelected ? Color.clear : Color.appOutline, lineWidth: Constants.borderWidth)
                        )
                        .shadow(
                            color: isSelected ? Color.appPrimary.opacity(Constants.glowAlpha) : .clear,
                            radius: Constants.glowRadius,
                            y: Constants.glowY
                        )
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

#Preview {
    @Previewable @State var selection: LibraryStatus = .playing
    StatusSelectGrid(selection: $selection)
        .padding(Spacing.md)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

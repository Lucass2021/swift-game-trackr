import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 20
    static let clearIconSize: CGFloat = 16
    static let clearTapSize: CGFloat = 44
    static let textSize: CGFloat = 16
    static let borderWidth: CGFloat = 1
}

struct CommunitySearchField: View {
    @Binding var query: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            AppIconView(icon: .search, size: Constants.iconSize)
                .foregroundStyle(Color.appTextSecondary)

            TextField(
                "",
                text: $query,
                prompt: Text("Search communities").foregroundStyle(Color.appTextSecondary)
            )
            .font(.appBody(Constants.textSize))
            .foregroundStyle(Color.appTextPrimary)
            .tint(Color.appPrimary)
            .autocorrectionDisabled()

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    AppIconView(icon: .close, size: Constants.clearIconSize)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(width: Constants.clearTapSize, height: Constants.clearTapSize)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Capsule().fill(Color.appSurfaceCard))
        .overlay(Capsule().stroke(Color.appOutline, lineWidth: Constants.borderWidth))
    }
}

#Preview {
    @Previewable @State var query = ""
    CommunitySearchField(query: $query)
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

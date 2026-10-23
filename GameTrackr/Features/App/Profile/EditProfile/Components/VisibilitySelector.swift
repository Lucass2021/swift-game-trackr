import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 20
    static let iconBoxWidth: CGFloat = 24
    static let titleSize: CGFloat = 15
    static let detailSize: CGFloat = 13
    static let detailSelectedOpacity = 0.75
    static let borderWidth: CGFloat = 1
}

struct VisibilitySelector: View {
    @Binding var selection: ProfileVisibility

    var body: some View {
        VStack(spacing: Spacing.xs) {
            ForEach(ProfileVisibility.allCases) { option in
                row(option)
            }
        }
    }

    private func row(_ option: ProfileVisibility) -> some View {
        let isSelected = option == selection

        return Button {
            selection = option
        } label: {
            HStack(spacing: Spacing.sm) {
                AppIconView(icon: option.icon, size: Constants.iconSize)
                    .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextSecondary)
                    .frame(width: Constants.iconBoxWidth)

                VStack(alignment: .leading, spacing: Spacing.xxxs) {
                    Text(option.title)
                        .font(.appLabel(Constants.titleSize))
                        .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextPrimary)

                    Text(option.detail)
                        .font(.appBody(Constants.detailSize))
                        .foregroundStyle(
                            isSelected
                                ? Color.appOnPrimary.opacity(Constants.detailSelectedOpacity)
                                : Color.appTextSecondary
                        )
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .fill(isSelected ? Color.appPrimary : Color.appSurfaceCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .stroke(isSelected ? Color.clear : Color.appOutline, lineWidth: Constants.borderWidth)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    @Previewable @State var selection: ProfileVisibility = .publicProfile
    VisibilitySelector(selection: $selection)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

import SwiftUI

private enum Constants {
    static let swatchSize: CGFloat = 46
    static let checkSize: CGFloat = 20
    static let borderWidth: CGFloat = 1
    static let selectedBorderWidth: CGFloat = 2
    static let gradientDepth = 0.28
}

struct AvatarColorPicker: View {
    let colors: [ProfileColor]
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(colors) { color in
                    swatch(color)
                }
            }
            .padding(.horizontal, Spacing.xxxs)
            .padding(.vertical, Spacing.xxxs)
        }
    }

    private func swatch(_ profileColor: ProfileColor) -> some View {
        let isSelected = profileColor.hex.caseInsensitiveCompare(selection) == .orderedSame

        return Button {
            selection = profileColor.hex
        } label: {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [profileColor.color, profileColor.color.darkened(by: Constants.gradientDepth)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: Constants.swatchSize, height: Constants.swatchSize)
                .overlay {
                    if isSelected {
                        AppIconView(icon: .check, size: Constants.checkSize)
                            .foregroundStyle(Color.appTextPrimary)
                    }
                }
                .overlay {
                    Circle()
                        .stroke(
                            isSelected ? Color.appPrimary : Color.appOutline,
                            lineWidth: isSelected ? Constants.selectedBorderWidth : Constants.borderWidth
                        )
                }
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(profileColor.name)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    @Previewable @State var selection = ProfileMockData.colors[0].hex
    AvatarColorPicker(
        colors: ProfileMockData.colors,
        selection: $selection
    )
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

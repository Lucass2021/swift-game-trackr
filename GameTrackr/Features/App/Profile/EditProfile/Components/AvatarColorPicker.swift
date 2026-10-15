import SwiftUI

struct AvatarColorPicker: View {
    let colors: [ProfileColor]
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(colors) { color in
                    swatch(color)
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 3)
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
                        colors: [profileColor.color, profileColor.color.darkened(by: 0.28)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 46, height: 46)
                .overlay {
                    if isSelected {
                        AppIconView(icon: .check, size: 20)
                            .foregroundStyle(Color.white)
                    }
                }
                .overlay {
                    Circle()
                        .stroke(
                            isSelected ? Color.appPrimary : Color.appOutline,
                            lineWidth: isSelected ? 2 : 1
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

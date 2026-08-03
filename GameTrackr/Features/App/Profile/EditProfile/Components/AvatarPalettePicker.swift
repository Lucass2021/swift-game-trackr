import SwiftUI

struct AvatarPalettePicker: View {
    @Binding var selection: AvatarPalette

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AvatarPalette.allCases) { palette in
                    swatch(palette)
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 3)
        }
    }

    private func swatch(_ palette: AvatarPalette) -> some View {
        let isSelected = palette == selection

        return Button {
            selection = palette
        } label: {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [palette.start, palette.end],
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
        .accessibilityLabel(palette.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    @Previewable @State var selection: AvatarPalette = .violet
    AvatarPalettePicker(selection: $selection)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

import SwiftUI

struct VisibilitySelector: View {
    @Binding var selection: ProfileVisibility

    var body: some View {
        VStack(spacing: 10) {
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
            HStack(spacing: 12) {
                AppIconView(icon: option.icon, size: 20)
                    .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextSecondary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 3) {
                    Text(option.title)
                        .font(.appLabel(15))
                        .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextPrimary)

                    Text(option.detail)
                        .font(.appBody(13))
                        .foregroundStyle(isSelected ? Color.appOnPrimary.opacity(0.75) : Color.appTextSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.appPrimary : Color.appSurfaceCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.clear : Color.appOutline, lineWidth: 1)
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

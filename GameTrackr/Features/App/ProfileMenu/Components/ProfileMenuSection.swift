import SwiftUI

struct ProfileMenuSection: View {
    let items: [ProfileMenuItem]
    let onItemSelect: (ProfileMenuItem) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element) { index, item in
                Button { onItemSelect(item) } label: {
                    row(item)
                }
                .buttonStyle(PressableButtonStyle())

                if index < items.count - 1 {
                    Divider()
                        .overlay(Color.appOutline)
                        .padding(.leading, Constants.dividerInset)
                }
            }
        }
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: Radius.lg))
    }

    private func row(_ item: ProfileMenuItem) -> some View {
        HStack(spacing: Spacing.sm) {
            AppIconView(icon: item.icon, size: Constants.iconSize)
                .foregroundStyle(Color.appPrimary)
                .frame(width: Constants.iconBoxWidth)
            Text(item.title)
                .font(.appLabel(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            AppIconView(icon: .forward, size: Constants.chevronSize)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(Spacing.md)
        .contentShape(Rectangle())
    }
}

private enum Constants {
    static let iconBoxWidth: CGFloat = 24
    static let iconSize: CGFloat = 20
    static let chevronSize: CGFloat = 16
    static let titleSize: CGFloat = 16
    static let dividerInset = Spacing.md + iconBoxWidth + Spacing.sm
}

#Preview {
    ProfileMenuSection(items: ProfileMenuItem.allCases) { _ in }
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

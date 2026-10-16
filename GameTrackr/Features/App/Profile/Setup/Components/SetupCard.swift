import SwiftUI

struct SetupCard: View {
    let setup: SetupItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                SetupCover(setup: setup, cornerRadius: 16, placeholderSize: 48)
                    .frame(height: 180)

                VStack(alignment: .leading, spacing: 4) {
                    Text(setup.title)
                        .font(.appHeadline(18))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)

                    if !setup.description.isEmpty {
                        Text(setup.description)
                            .font(.appBody(14))
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    SetupCard(setup: ProfileMockData.setups[0], onTap: {})
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

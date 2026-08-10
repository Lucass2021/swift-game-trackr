import SwiftUI

struct ProfileSetupSection: View {
    let setups: [SetupItem]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(setups) { item in
                    card(item)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func card(_ item: SetupItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [item.imageStart, item.imageEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160, height: 120)
                .overlay {
                    AppIconView(icon: .brand, size: 38)
                        .foregroundStyle(Color.white.opacity(0.18))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.appOutline, lineWidth: 1)
                }

            Text(item.title)
                .font(.appLabel(14))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)

            Text(item.description)
                .font(.appBody(12))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 160)
    }
}

#Preview {
    ProfileSetupSection(setups: ProfileMockData.setups)
        .padding(.vertical, 20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

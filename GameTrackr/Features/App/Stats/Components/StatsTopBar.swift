import SwiftUI

struct StatsTopBar: View {
    let title: String
    var subtitle: String?
    let onBack: () -> Void
    var onShare: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                AppIconView(icon: .back, size: 22)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.appHeadline(22))
                    .foregroundStyle(Color.appTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.appBody(13))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer(minLength: 8)

            Button(action: onShare) {
                AppIconView(icon: .share, size: 22)
                    .foregroundStyle(Color.appSecondary)
                    .frame(width: 40, height: 40, alignment: .trailing)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Share stats")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.appBackground)
    }
}

#Preview {
    StatsTopBar(title: "Your Stats", onBack: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

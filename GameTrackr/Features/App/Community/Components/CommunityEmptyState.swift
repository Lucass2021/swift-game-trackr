import SwiftUI

struct CommunityEmptyState: View {
    let icon: AppIcon
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            AppIconView(icon: icon, size: 56)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 120, height: 120)
                .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .subtleBounce()

            Text(title)
                .font(.appHeadline(24, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 26)

            Text(message)
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 24)

            Button(action: action) {
                Text(actionTitle)
                    .font(.appLabel(16))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 15)
                    .background(Capsule().fill(Color.appPrimary))
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.top, 28)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 60)
    }
}

#Preview {
    CommunityEmptyState(
        icon: .community,
        title: "Your feed is quiet",
        message: "Join a community to see posts from other players here.",
        actionTitle: "Discover communities",
        action: {}
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

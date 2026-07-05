import SwiftUI

struct NotificationsEmptyState: View {
    let title: String
    let subtitle: String
    var actionTitle: String?
    var onAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            AppIconView(icon: .notifications, size: 56)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 120, height: 120)
                .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: Color.appPrimary.opacity(0.35), radius: 30)
                .subtleBounce()

            Text(title)
                .font(.appHeadline(24, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 28)

            Text(subtitle)
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 24)

            if let actionTitle, let onAction {
                PrimaryButton(title: actionTitle, action: onAction)
                    .padding(.top, 28)
                    .padding(.horizontal, 32)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NotificationsEmptyState(
        title: "You're all caught up",
        subtitle: "New notifications will show up here."
    )
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

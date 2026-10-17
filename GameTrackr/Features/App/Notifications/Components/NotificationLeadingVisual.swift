import SwiftUI

private enum Constants {
    static let visualSize: CGFloat = 48
    static let iconSize: CGFloat = 24
    static let borderWidth: CGFloat = 1
    static let onlineBadgeSize: CGFloat = 13
    static let acceptedBadgeSize: CGFloat = 16
}

struct NotificationLeadingVisual: View {
    let leading: NotificationLeading

    var body: some View {
        switch leading {
        case let .avatar(start, end, badge):
            avatar(start: start, end: end, badge: badge)
        case let .iconBox(icon, tint):
            iconBox(icon: icon, tint: tint)
        case let .thumbnail(start, end):
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(gradient(start, end))
                .frame(width: Constants.visualSize, height: Constants.visualSize)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
                )
        }
    }

    private func avatar(start: Color, end: Color, badge: AvatarBadge?) -> some View {
        Circle()
            .fill(gradient(start, end))
            .frame(width: Constants.visualSize, height: Constants.visualSize)
            .overlay(Circle().stroke(Color.appOutline, lineWidth: Constants.borderWidth))
            .overlay(alignment: .bottomTrailing) {
                badgeView(badge)
            }
    }

    @ViewBuilder
    private func badgeView(_ badge: AvatarBadge?) -> some View {
        switch badge {
        case .online:
            Circle()
                .fill(Color.appPrimary)
                .frame(width: Constants.onlineBadgeSize, height: Constants.onlineBadgeSize)
                .overlay(Circle().stroke(Color.appBackground, lineWidth: Spacing.xxxs))
        case .accepted:
            AppIconView(icon: .success, filled: true, size: Constants.acceptedBadgeSize)
                .foregroundStyle(Color.appPrimary)
                .background(
                    Circle()
                        .fill(Color.appBackground)
                        .frame(width: Constants.acceptedBadgeSize, height: Constants.acceptedBadgeSize)
                )
        case .none:
            EmptyView()
        }
    }

    private func iconBox(icon: AppIcon, tint: Color) -> some View {
        AppIconView(icon: icon, size: Constants.iconSize)
            .foregroundStyle(tint)
            .frame(width: Constants.visualSize, height: Constants.visualSize)
            .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
            )
    }

    private func gradient(_ start: Color, _ end: Color) -> LinearGradient {
        LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

#Preview {
    HStack(spacing: Spacing.md) {
        ForEach(NotificationsMockData.items) { item in
            NotificationLeadingVisual(leading: item.leading)
        }
    }
    .padding(Spacing.md)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

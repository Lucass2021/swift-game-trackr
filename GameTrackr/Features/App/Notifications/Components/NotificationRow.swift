import SwiftUI

struct NotificationRow: View {
    let item: NotificationItem
    let markedAllRead: Bool
    var onAccept: () -> Void = {}
    var onDecline: () -> Void = {}

    private var isUnread: Bool {
        item.unread && !markedAllRead
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            NotificationLeadingView(leading: item.leading)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    styledLine
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(item.timestamp)
                        .font(.appBody(12))
                        .foregroundStyle(Color.appTextSecondary)

                    if isUnread, item.trailingDot {
                        Circle()
                            .fill(Color.appPrimary)
                            .frame(width: 10, height: 10)
                            .padding(.top, 4)
                    }
                }

                if let secondary = item.secondary {
                    secondaryView(secondary)
                }

                if item.isFriendRequest {
                    friendRequestActions
                }
            }
        }
        .padding(14)
        .background(rowBackground)
    }

    private var styledLine: Text {
        item.spans.reduce(Text("")) { partial, span in
            partial + Text(span.text)
                .font(font(for: span.style))
                .foregroundColor(color(for: span.style))
        }
    }

    private func font(for style: NotificationSpanStyle) -> Font {
        style == .text ? .appBody(15) : .appLabel(15)
    }

    private func color(for style: NotificationSpanStyle) -> Color {
        switch style {
        case .actor: .appTextPrimary
        case .text: .appTextSecondary
        case .link: .appSecondary
        case .highlight: .appPrimary
        }
    }

    @ViewBuilder
    private func secondaryView(_ text: String) -> some View {
        if item.secondaryIsQuote {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(Color.appOutline)
                    .frame(width: 2)
                Text(text)
                    .font(.appBody(14).italic())
                    .foregroundStyle(Color.appTextSecondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(text)
                .font(.appBody(14))
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var friendRequestActions: some View {
        HStack(spacing: 12) {
            Button(action: onAccept) {
                Text("Accept")
                    .font(.appLabel(14))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 9)
                    .background(Color.appPrimary, in: Capsule())
            }
            .buttonStyle(PressableButtonStyle())

            Button(action: onDecline) {
                Text("Decline")
                    .font(.appLabel(14))
                    .foregroundStyle(Color.appTertiary)
                    .padding(.vertical, 9)
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.top, 2)
    }

    @ViewBuilder
    private var rowBackground: some View {
        if item.section == .new {
            let border = item.isFriendRequest ? Color.appPrimary.opacity(0.45) : Color.appOutline
            let fill = item.isFriendRequest ? Color.appPrimary.opacity(0.06) : Color.appSurfaceCard
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(fill)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(border, lineWidth: 1)
                )
        } else {
            Color.clear
        }
    }
}

private struct NotificationLeadingView: View {
    let leading: NotificationLeading

    var body: some View {
        switch leading {
        case let .avatar(start, end, badge):
            avatar(start: start, end: end, badge: badge)
        case let .iconBox(icon, tint):
            iconBox(icon: icon, tint: tint)
        case let .thumbnail(start, end):
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(gradient(start, end))
                .frame(width: 48, height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.appOutline, lineWidth: 1)
                )
        }
    }

    private func avatar(start: Color, end: Color, badge: AvatarBadge?) -> some View {
        Circle()
            .fill(gradient(start, end))
            .frame(width: 48, height: 48)
            .overlay(Circle().stroke(Color.appOutline, lineWidth: 1))
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
                .frame(width: 13, height: 13)
                .overlay(Circle().stroke(Color.appBackground, lineWidth: 2))
        case .accepted:
            AppIconView(icon: .success, filled: true, size: 16)
                .foregroundStyle(Color.appPrimary)
                .background(Circle().fill(Color.appBackground).frame(width: 16, height: 16))
        case .none:
            EmptyView()
        }
    }

    private func iconBox(icon: AppIcon, tint: Color) -> some View {
        AppIconView(icon: icon, size: 24)
            .foregroundStyle(tint)
            .frame(width: 48, height: 48)
            .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: 1)
            )
    }

    private func gradient(_ start: Color, _ end: Color) -> LinearGradient {
        LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

#Preview {
    VStack(spacing: 4) {
        NotificationRow(item: NotificationsMockData.items[0], markedAllRead: false)
        NotificationRow(item: NotificationsMockData.items[2], markedAllRead: false)
        NotificationRow(item: NotificationsMockData.items[6], markedAllRead: false)
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

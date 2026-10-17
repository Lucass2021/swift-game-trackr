import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let unreadDotSize: CGFloat = 10
    static let quoteBarWidth: CGFloat = 2
    static let friendRequestFillAlpha = 0.06
    static let friendRequestBorderAlpha = 0.45
    static let lineSize: CGFloat = 15
    static let timestampSize: CGFloat = 12
    static let secondarySize: CGFloat = 14
}

struct NotificationRow: View {
    let item: NotificationItem
    var onAccept: () -> Void = {}
    var onDecline: () -> Void = {}

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            NotificationLeadingVisual(leading: item.leading)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(alignment: .top, spacing: Spacing.xs) {
                    Text(styledLine)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(item.timestamp)
                        .font(.appBody(Constants.timestampSize))
                        .foregroundStyle(Color.appTextSecondary)

                    if item.unread, item.trailingDot {
                        Circle()
                            .fill(Color.appPrimary)
                            .frame(width: Constants.unreadDotSize, height: Constants.unreadDotSize)
                            .padding(.top, Spacing.xxs)
                    }
                }

                if let secondary = item.secondary {
                    secondaryView(secondary)
                }

                if item.isFriendRequest {
                    FriendRequestActions(onAccept: onAccept, onDecline: onDecline)
                }
            }
        }
        .padding(Spacing.sm)
        .background(rowBackground)
    }

    private var styledLine: AttributedString {
        item.spans.reduce(into: AttributedString()) { line, span in
            var part = AttributedString(span.text)
            part.font = span.style == .text ? .appBody(Constants.lineSize) : .appLabel(Constants.lineSize)
            part.foregroundColor = color(for: span.style)
            line += part
        }
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
            HStack(spacing: Spacing.xs) {
                Rectangle()
                    .fill(Color.appOutline)
                    .frame(width: Constants.quoteBarWidth)
                Text(text)
                    .font(.appBody(Constants.secondarySize).italic())
                    .foregroundStyle(Color.appTextSecondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(text)
                .font(.appBody(Constants.secondarySize))
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var rowBackground: some View {
        if item.section == .new {
            let border = item.isFriendRequest
                ? Color.appPrimary.opacity(Constants.friendRequestBorderAlpha)
                : Color.appOutline
            let fill = item.isFriendRequest
                ? Color.appPrimary.opacity(Constants.friendRequestFillAlpha)
                : Color.appSurfaceCard
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(fill)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                        .stroke(border, lineWidth: Constants.borderWidth)
                )
        } else {
            Color.clear
        }
    }
}

#Preview {
    VStack(spacing: Spacing.xxs) {
        NotificationRow(item: NotificationsMockData.items[0])
        NotificationRow(item: NotificationsMockData.items[2])
        NotificationRow(item: NotificationsMockData.items[6])
    }
    .padding(Spacing.md)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

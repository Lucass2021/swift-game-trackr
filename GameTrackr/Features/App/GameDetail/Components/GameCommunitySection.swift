import SwiftUI

struct GameCommunitySection: View {
    let discussions: [GameDiscussion]
    var onSeeAll: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GameSectionHeader(title: "Community", actionTitle: "See all discussions", action: onSeeAll)

            VStack(spacing: 12) {
                ForEach(discussions) { DiscussionCard(discussion: $0) }
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct DiscussionCard: View {
    let discussion: GameDiscussion

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color.appPrimary)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [discussion.avatarStart, discussion.avatarEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                        .overlay(
                            AppIconView(icon: .avatar, size: 16)
                                .foregroundStyle(Color.white.opacity(0.7))
                        )

                    Text(discussion.author)
                        .font(.appLabel(14))
                        .foregroundStyle(Color.appPrimary)

                    Spacer()

                    Text(discussion.timeAgo)
                        .font(.appBody(12))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Text(discussion.title)
                    .font(.appHeadline(17))
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(discussion.preview)
                    .font(.appBody(14))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 18) {
                    metric(icon: .community, value: discussion.comments)
                    metric(icon: .like, value: discussion.likes)
                }
                .padding(.top, 2)
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func metric(icon: AppIcon, value: Int) -> some View {
        HStack(spacing: 6) {
            AppIconView(icon: icon, size: 15)
                .foregroundStyle(Color.appTextSecondary)
            Text("\(value)")
                .font(.appBody(13))
                .foregroundStyle(Color.appTextSecondary)
        }
    }
}

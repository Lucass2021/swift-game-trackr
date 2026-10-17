import SwiftUI

private enum Constants {
    static let avatarSize: CGFloat = 88
    static let avatarOverhang: CGFloat = 44
    static let avatarBorderWidth: CGFloat = 4
    static let bannerHeight: CGFloat = 150
    static let bannerIconSize: CGFloat = 64
    static let bannerIconAlpha = 0.08
    static let nameSize: CGFloat = 24
    static let usernameSize: CGFloat = 14
    static let bioSize: CGFloat = 15
    static let joinedSize: CGFloat = 13
}

struct ProfileHeader: View {
    private static let joinedFormat = Date.FormatStyle(locale: Locale(identifier: "en_US"), timeZone: .gmt).month(.wide)
        .year()

    let profile: Profile
    var mode: ProfileHeaderMode = .own
    var isGuest = false
    var onEdit: () -> Void = {}
    var shareText: String = ""
    var onAddFriend: () -> Void = {}
    var onMessage: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            banner

            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(alignment: .bottom, spacing: Spacing.sm) {
                    CommunityAvatar(start: profile.avatarStart, end: profile.avatarEnd, size: Constants.avatarSize)
                        .overlay(
                            Circle().stroke(Color.appBackground, lineWidth: Constants.avatarBorderWidth)
                        )

                    VStack(alignment: .leading, spacing: Spacing.xxxs) {
                        Text(profile.name)
                            .font(.appHeadline(Constants.nameSize, weight: .heavy))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(1)

                        Text(profile.username)
                            .font(.appBody(Constants.usernameSize))
                            .foregroundStyle(Color.appPrimary)
                    }
                    .padding(.bottom, Spacing.xxs)

                    Spacer(minLength: 0)
                }

                if !profile.bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(profile.bio)
                        .font(.appBody(Constants.bioSize))
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let joinedAt = profile.joinedAt {
                    Text("Joined \(joinedAt.formatted(Self.joinedFormat))")
                        .font(.appBody(Constants.joinedSize))
                        .foregroundStyle(Color.appTextSecondary)
                }

                ProfileHeaderActions(
                    mode: mode,
                    isGuest: isGuest,
                    shareText: shareText,
                    onEdit: onEdit,
                    onAddFriend: onAddFriend,
                    onMessage: onMessage
                )
            }
            .padding(.horizontal, Spacing.lg)
            .offset(y: -Constants.avatarOverhang)
            .padding(.bottom, Spacing.sm - Constants.avatarOverhang)
        }
    }

    private var banner: some View {
        LinearGradient(
            colors: [profile.avatarStart, profile.avatarEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: Constants.bannerHeight)
        .overlay {
            LinearGradient(
                colors: [.clear, Color.appBackground],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .overlay {
            AppIconView(icon: .brand, size: Constants.bannerIconSize)
                .foregroundStyle(Color.white.opacity(Constants.bannerIconAlpha))
        }
    }
}

#Preview {
    ScrollView {
        ProfileHeader(profile: ProfileMockData.profile)
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

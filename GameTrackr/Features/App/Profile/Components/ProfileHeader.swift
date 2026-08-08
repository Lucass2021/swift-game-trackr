import SwiftUI

struct ProfileHeader: View {
    let profile: Profile
    var mode: ProfileHeaderMode = .own
    var onEdit: () -> Void = {}
    var shareText: String = ""
    var onAddFriend: () -> Void = {}
    var onMessage: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            banner

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .bottom, spacing: 14) {
                    CommunityAvatar(start: profile.avatarStart, end: profile.avatarEnd, size: 88)
                        .overlay(
                            Circle().stroke(Color.appBackground, lineWidth: 4)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(profile.name)
                            .font(.appHeadline(24, weight: .heavy))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(1)

                        Text(profile.username)
                            .font(.appBody(14))
                            .foregroundStyle(Color.appPrimary)
                    }
                    .padding(.bottom, 6)

                    Spacer(minLength: 0)
                }

                Text(profile.bio)
                    .font(.appBody(15))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(profile.joinedAt)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTextSecondary)

                actions
            }
            .padding(.horizontal, 20)
            .offset(y: -44)
            .padding(.bottom, -30)
        }
    }

    private var banner: some View {
        LinearGradient(
            colors: [profile.avatarStart, profile.avatarEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 150)
        .overlay {
            LinearGradient(
                colors: [.clear, Color.appBackground],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .overlay {
            AppIconView(icon: .brand, size: 64)
                .foregroundStyle(Color.white.opacity(0.08))
        }
    }

    @ViewBuilder
    private var actions: some View {
        switch mode {
        case .own:
            HStack(spacing: 12) {
                primaryPill(icon: .editProfile, title: "Edit profile", action: onEdit)
                circleShareLink(label: "Share profile")
            }
        case let .other(isFriend):
            HStack(spacing: 12) {
                if isFriend {
                    secondaryPill(icon: .check, title: "Friends", action: onAddFriend)
                } else {
                    primaryPill(icon: .addFriend, title: "Add friend", action: onAddFriend)
                }
                circleAction(icon: .envelope, label: "Send message", action: onMessage)
                circleShareLink(label: "Share profile")
            }
        }
    }

    private func primaryPill(icon: AppIcon, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                AppIconView(icon: icon, size: 18)
                Text(title)
                    .font(.appLabel(15))
            }
            .foregroundStyle(Color.appOnPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Capsule().fill(Color.appPrimary))
            .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func secondaryPill(icon: AppIcon, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                AppIconView(icon: icon, size: 18)
                Text(title)
                    .font(.appLabel(15))
            }
            .foregroundStyle(Color.appTextPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Capsule().stroke(Color.appOutline, lineWidth: 1))
            .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func circleAction(icon: AppIcon, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            AppIconView(icon: icon, size: 20)
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: 46, height: 46)
                .background(Circle().stroke(Color.appOutline, lineWidth: 1))
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(label)
    }

    private func circleShareLink(label: String) -> some View {
        ShareLink(item: shareText) {
            AppIconView(icon: .share, size: 20)
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: 46, height: 46)
                .background(Circle().stroke(Color.appOutline, lineWidth: 1))
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(label)
    }
}

#Preview {
    ScrollView {
        ProfileHeader(profile: ProfileMockData.profile)
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

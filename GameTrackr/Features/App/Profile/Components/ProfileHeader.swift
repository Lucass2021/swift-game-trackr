import SwiftUI

struct ProfileHeader: View {
    let profile: Profile
    var onEdit: () -> Void = {}
    var onShare: () -> Void = {}

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

    private var actions: some View {
        HStack(spacing: 12) {
            Button(action: onEdit) {
                HStack(spacing: 8) {
                    AppIconView(icon: .editProfile, size: 18)
                    Text("Edit profile")
                        .font(.appLabel(15))
                }
                .foregroundStyle(Color.appOnPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Capsule().fill(Color.appPrimary))
                .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())

            Button(action: onShare) {
                AppIconView(icon: .share, size: 20)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 46, height: 46)
                    .background(Circle().stroke(Color.appOutline, lineWidth: 1))
                    .contentShape(Circle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Share profile")
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

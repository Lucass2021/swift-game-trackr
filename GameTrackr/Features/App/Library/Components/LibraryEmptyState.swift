import SwiftUI

struct LibraryEmptyState: View {
    let onBrowse: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            AppIconView(icon: .brand, size: 60)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 128, height: 128)
                .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                .shadow(color: Color.appPrimary.opacity(0.25), radius: 34)
                .subtleBounce()

            Text("Your library is empty")
                .font(.appHeadline(26, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 28)

            Text("Find games to start tracking your journey and building your ultimate collection.")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 32)

            Button(action: onBrowse) {
                HStack(spacing: 10) {
                    Text("Browse games")
                    AppIconView(icon: .forward, size: 18)
                }
                .font(.appLabel(16))
                .foregroundStyle(Color.appOnPrimary)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(Capsule().fill(Color.appPrimary))
                .shadow(color: Color.appPrimary.opacity(0.35), radius: 24)
                .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.top, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
    }
}

#Preview {
    LibraryEmptyState(onBrowse: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

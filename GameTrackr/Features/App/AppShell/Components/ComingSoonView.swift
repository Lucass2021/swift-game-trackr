import SwiftUI

struct ComingSoonView: View {
    let icon: AppIcon
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 14) {
            AppIconView(icon: icon, size: 40)
                .foregroundStyle(Color.appPrimary)

            Text(title)
                .font(.appHeadline(22))
                .foregroundStyle(Color.appTextPrimary)

            Text(subtitle)
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

#Preview {
    ComingSoonView(icon: .library, title: "Library", subtitle: "Your game library is coming next.")
        .preferredColorScheme(.dark)
}

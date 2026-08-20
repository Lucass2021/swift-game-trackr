import SwiftUI

struct HomeSectionRetry: View {
    let message: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.appBody(14))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            Button("Try again", action: action)
                .font(.appLabel(14))
                .foregroundStyle(Color.appPrimary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .padding(.horizontal, 20)
    }
}

#Preview {
    HomeSectionRetry(message: "Couldn't load new releases.", action: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

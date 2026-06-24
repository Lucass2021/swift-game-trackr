import SwiftUI

struct SocialLoginSection: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                line
                Text("OR CONTINUE WITH")
                    .font(.appLabel(12))
                    .foregroundStyle(Color.appTextSecondary)
                    .tracking(1)
                    .fixedSize()
                line
            }

            Button(action: action) {
                HStack(spacing: 12) {
                    Text("G")
                        .font(.appHeadline(18))
                        .foregroundStyle(Color.appOnPrimary)
                        .frame(width: 26, height: 26)
                        .background(Color.appTextPrimary)
                        .clipShape(Circle())

                    Text("Continue with Google")
                        .font(.appLabel(16))
                        .foregroundStyle(Color.appTextPrimary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.appSurfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appOutline, lineWidth: 1)
                )
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private var line: some View {
        Rectangle()
            .fill(Color.appOutline)
            .frame(height: 1)
    }
}

#Preview {
    SocialLoginSection {}
        .padding()
        .background(Color.appBackground)
}

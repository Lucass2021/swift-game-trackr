import SwiftUI

struct ResendRow: View {
    let seconds: Int
    let onResend: () -> Void

    var body: some View {
        if seconds <= 0 {
            AuthPrompt(prefix: "Didn't get it? ", actionText: "Resend code", action: onResend)
        } else {
            Text("Didn't get it? Resend in \(seconds)s")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        ResendRow(seconds: 12) {}
        ResendRow(seconds: 0) {}
    }
    .padding()
    .background(Color.appBackground)
}

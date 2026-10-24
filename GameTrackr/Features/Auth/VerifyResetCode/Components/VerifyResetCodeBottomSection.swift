import SwiftUI

struct VerifyResetCodeBottomSection: View {
    let seconds: Int
    let onResend: () -> Void
    let isLoading: Bool
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            ResendRow(seconds: seconds, onResend: onResend)

            PrimaryButton(title: "Confirm", isLoading: isLoading, action: onConfirm)
        }
    }
}

#Preview {
    VerifyResetCodeBottomSection(seconds: 12, onResend: {}, isLoading: false, onConfirm: {})
        .padding()
        .background(Color.appBackground)
}

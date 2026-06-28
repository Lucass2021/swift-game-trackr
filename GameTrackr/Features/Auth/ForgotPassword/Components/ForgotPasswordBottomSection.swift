import SwiftUI

struct ForgotPasswordBottomSection: View {
    @Bindable var viewModel: ForgotPasswordViewModel
    let onBackToLogin: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            PrimaryButton(title: "Send code", isLoading: viewModel.isLoading) {
                Task { await viewModel.sendCode() }
            }

            Button(action: onBackToLogin) {
                Text("Back to login")
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appSecondary)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ForgotPasswordBottomSection(viewModel: ForgotPasswordViewModel(), onBackToLogin: {})
        .padding()
        .background(Color.appBackground)
}

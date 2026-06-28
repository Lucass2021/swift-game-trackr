import SwiftUI

struct VerifyResetCodeBottomSection: View {
    @Bindable var viewModel: VerifyResetCodeViewModel

    var body: some View {
        VStack(spacing: 20) {
            resendRow

            PrimaryButton(title: "Confirm", isLoading: viewModel.isLoading) {
                Task { await viewModel.verify() }
            }
        }
    }

    @ViewBuilder
    private var resendRow: some View {
        if viewModel.canResend {
            Button {
                Task { await viewModel.resend() }
            } label: {
                Text("Didn't get it? \(Text("Resend code").foregroundStyle(Color.appSecondary))")
                    .font(.appBody(15))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .buttonStyle(.plain)
        } else {
            Text("Didn't get it? Resend in \(viewModel.secondsRemaining)s")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
        }
    }
}

#Preview {
    VerifyResetCodeBottomSection(viewModel: VerifyResetCodeViewModel(email: "you@email.com"))
        .padding()
        .background(Color.appBackground)
}

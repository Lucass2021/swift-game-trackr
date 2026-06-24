import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = RegisterViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        return AuthScreenScaffold {
            backButton
                .staggeredAppear(0)

            TitleWithSubtitle(
                title: "Create your profile",
                subTitle: "Join the global community of players."
            )
            .padding(.top, 16)
            .staggeredAppear(1)

            RegisterFormSection(viewModel: viewModel)
                .padding(.top, 28)
                .staggeredAppear(2)

            TermsAcceptanceRow(isAccepted: $viewModel.acceptedTerms, error: viewModel.termsError)
                .padding(.top, 24)
                .staggeredAppear(3)

            RegisterBottomSection(
                isLoading: viewModel.isLoading,
                onCreateAccount: { Task { await viewModel.signUp() } },
                onSignIn: { dismiss() }
            )
            .padding(.top, 24)
            .staggeredAppear(4)

            SocialLoginSection(action: { viewModel.signUpGoogle() })
                .padding(.top, 28)
                .staggeredAppear(5)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear { viewModel.clear() }
    }

    private var backButton: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40, alignment: .leading)
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
    .preferredColorScheme(.dark)
}

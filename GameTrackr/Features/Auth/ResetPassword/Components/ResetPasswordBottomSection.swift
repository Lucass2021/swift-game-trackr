import SwiftUI

struct ResetPasswordBottomSection: View {
    @Bindable var viewModel: ResetPasswordViewModel
    let onSave: () -> Void

    var body: some View {
        PrimaryButton(title: "Save new password", isLoading: viewModel.isLoading, action: onSave)
    }
}

#Preview {
    ResetPasswordBottomSection(
        viewModel: ResetPasswordViewModel(email: "you@email.com", code: "123456"),
        onSave: {}
    )
    .padding()
    .background(Color.appBackground)
}

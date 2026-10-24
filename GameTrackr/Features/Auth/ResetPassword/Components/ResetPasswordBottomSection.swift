import SwiftUI

struct ResetPasswordBottomSection: View {
    let isLoading: Bool
    let onSave: () -> Void

    var body: some View {
        PrimaryButton(title: "Save new password", isLoading: isLoading, action: onSave)
    }
}

#Preview {
    ResetPasswordBottomSection(isLoading: false) {}
        .padding()
        .background(Color.appBackground)
}

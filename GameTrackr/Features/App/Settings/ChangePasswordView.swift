import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var submitted = false
    @State private var showSuccess = false

    private var strength: PasswordStrength {
        PasswordStrength(password: newPassword)
    }

    private var currentPasswordError: String? {
        guard submitted, currentPassword.isEmpty else { return nil }
        return "Current password is required"
    }

    private var newPasswordError: String? {
        guard submitted, !newPassword.isEmpty else {
            if submitted, newPassword.isEmpty { return "New password is required" }
            return nil
        }
        if newPassword.count < 6 { return "At least 6 characters" }
        return nil
    }

    private var confirmError: String? {
        guard submitted, !confirmPassword.isEmpty else {
            if submitted, confirmPassword.isEmpty { return "Confirm your new password" }
            return nil
        }
        if confirmPassword != newPassword { return "Passwords do not match" }
        return nil
    }

    private var canSave: Bool {
        !currentPassword.isEmpty
            && newPassword.count >= 6
            && confirmPassword == newPassword
    }

    var body: some View {
        if showSuccess {
            SuccessView(
                title: "Password updated!",
                subtitle: "Your password was changed successfully.",
                buttonTitle: "Done",
                onPrimary: { dismiss() }
            )
        } else {
            formContent
        }
    }

    private var formContent: some View {
        VStack(spacing: 0) {
            StatsTopBar(title: "Change password", onBack: { dismiss() })

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    AuthLabeledField(label: "Current password") {
                        AuthTextField(
                            placeholder: "••••••••",
                            text: $currentPassword,
                            isSecure: true,
                            contentType: .password,
                            error: currentPasswordError
                        )
                    }

                    AuthLabeledField(label: "New password") {
                        AuthTextField(
                            placeholder: "••••••••",
                            text: $newPassword,
                            isSecure: true,
                            contentType: .newPassword,
                            error: newPasswordError
                        )

                        if !newPassword.isEmpty {
                            PasswordStrengthMeter(strength: strength)
                        }
                    }

                    AuthLabeledField(label: "Confirm new password") {
                        AuthTextField(
                            placeholder: "••••••••",
                            text: $confirmPassword,
                            isSecure: true,
                            contentType: .newPassword,
                            error: confirmError
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }

            PrimaryButton(title: "Save new password") { save() }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .opacity(canSave ? 1 : 0.45)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private func save() {
        submitted = true
        guard canSave else { return }
        showSuccess = true
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView()
    }
    .preferredColorScheme(.dark)
}

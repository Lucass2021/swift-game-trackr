import SwiftUI

struct RememberMeRow: View {
    @Binding var rememberMe: Bool
    var onForgotPassword: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                rememberMe.toggle()
            } label: {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(rememberMe ? Color.appPrimary : Color.clear)
                        .frame(width: 22, height: 22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(rememberMe ? Color.appPrimary : Color.appOutline, lineWidth: 1.5)
                        )
                        .overlay {
                            if rememberMe {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Color.appOnPrimary)
                            }
                        }

                    Text("Remember me")
                        .font(.appBody(15))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onForgotPassword) {
                Text("Forgot my password")
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appSecondary)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    @Previewable @State var rememberMe = false
    RememberMeRow(rememberMe: $rememberMe, onForgotPassword: {})
        .padding()
        .background(Color.appBackground)
}

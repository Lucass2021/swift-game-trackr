import SwiftUI

struct ForgotPasswordRow: View {
    var onForgotPassword: () -> Void

    var body: some View {
        Button(action: onForgotPassword) {
            Text("Forgot my password")
                .font(.appLabel(15))
                .foregroundStyle(Color.appSecondary)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    ForgotPasswordRow(onForgotPassword: {})
        .padding()
        .background(Color.appBackground)
}

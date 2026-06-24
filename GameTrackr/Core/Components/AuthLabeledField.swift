import SwiftUI

struct AuthLabeledField<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.appLabel(15))
                .foregroundStyle(Color.appTextSecondary)

            content
        }
    }
}

#Preview {
    AuthLabeledField(label: "Email") {
        AuthTextField(placeholder: "you@email.com", text: .constant(""))
    }
    .padding()
    .background(Color.appBackground)
}

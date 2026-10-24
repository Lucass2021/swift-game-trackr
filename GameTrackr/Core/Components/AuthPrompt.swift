import SwiftUI

struct AuthPrompt: View {
    let prefix: String
    let actionText: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(prefix)\(Text(actionText).font(.appLabel(15)).foregroundStyle(Color.appSecondary))")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AuthPrompt(prefix: "Don't have an account? ", actionText: "Sign up") {}
        .padding()
        .background(Color.appBackground)
}

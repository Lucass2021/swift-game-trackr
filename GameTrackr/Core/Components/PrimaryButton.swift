import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(Color.appOnPrimary)
                } else {
                    Text(title)
                        .font(.appLabel(17))
                        .foregroundStyle(Color.appOnPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.appPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isLoading)
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Create account") {}
        PrimaryButton(title: "Loading", isLoading: true) {}
    }
    .padding()
    .background(Color.appBackground)
}

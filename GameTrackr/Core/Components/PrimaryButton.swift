import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var icon: AppIcon?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(Color.appOnPrimary)
                } else {
                    HStack(spacing: 10) {
                        if let icon {
                            AppIconView(icon: icon, size: 20)
                                .foregroundStyle(Color.appOnPrimary)
                        }
                        Text(title)
                            .font(.appLabel(17))
                            .foregroundStyle(Color.appOnPrimary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.appPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.appPrimary.opacity(0.45), radius: 22, y: 4)
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

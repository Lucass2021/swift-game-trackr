import SwiftUI

struct SetupDeleteButton: View {
    let isDeleting: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                if isDeleting {
                    ProgressView()
                        .tint(Color.appTertiary)
                } else {
                    AppIconView(icon: .trash, size: 18)
                }
                Text("Delete setup")
                    .font(.appLabel(16))
            }
            .foregroundStyle(Color.appTertiary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.appTertiary.opacity(0.4), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    SetupDeleteButton(isDeleting: false, onTap: {})
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

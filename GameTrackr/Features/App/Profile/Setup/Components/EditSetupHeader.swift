import SwiftUI

struct EditSetupHeader: View {
    let isNew: Bool
    let isSaving: Bool
    let onClose: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onClose) {
                AppIconView(icon: .close, size: 20)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Close")

            Text(isNew ? "New setup" : "Edit setup")
                .font(.appHeadline(20))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Button(action: onSave) {
                ZStack {
                    if isSaving {
                        ProgressView()
                            .tint(Color.appOnPrimary)
                    } else {
                        Text("Save")
                            .font(.appLabel(15))
                            .foregroundStyle(Color.appOnPrimary)
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 38)
                .background(Capsule().fill(Color.appPrimary))
                .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    EditSetupHeader(isNew: true, isSaving: false, onClose: {}, onSave: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

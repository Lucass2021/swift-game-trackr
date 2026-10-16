import SwiftUI

struct MySetupHeader: View {
    let showAdd: Bool
    let onBack: () -> Void
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                AppIconView(icon: .back, size: 22)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Back")

            Text("My Setup")
                .font(.appHeadline(20))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            if showAdd {
                Button(action: onAdd) {
                    AppIconView(icon: .plus, size: 20)
                        .foregroundStyle(Color.appOnPrimary)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(Color.appPrimary))
                        .contentShape(Circle())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Add setup")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    MySetupHeader(showAdd: true, onBack: {}, onAdd: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

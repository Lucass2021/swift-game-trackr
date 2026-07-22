import SwiftUI

struct JoinButton: View {
    let isJoined: Bool
    var expanded = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isJoined {
                    AppIconView(icon: .check, size: 14)
                }
                Text(isJoined ? "Joined" : "Join")
            }
            .font(.appLabel(14))
            .foregroundStyle(isJoined ? Color.appTextPrimary : Color.appOnPrimary)
            .padding(.horizontal, expanded ? 28 : 20)
            .padding(.vertical, expanded ? 15 : 10)
            .frame(maxWidth: expanded ? .infinity : nil)
            .background(Capsule().fill(isJoined ? Color.clear : Color.appPrimary))
            .overlay(Capsule().stroke(isJoined ? Color.appOutline : Color.clear, lineWidth: 1))
            .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    HStack(spacing: 12) {
        JoinButton(isJoined: false, action: {})
        JoinButton(isJoined: true, action: {})
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

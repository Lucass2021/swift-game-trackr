import SwiftUI

struct CommunitySearchField: View {
    @Binding var query: String

    var body: some View {
        HStack(spacing: 12) {
            AppIconView(icon: .search, size: 20)
                .foregroundStyle(Color.appTextSecondary)

            TextField(
                "",
                text: $query,
                prompt: Text("Search communities").foregroundStyle(Color.appTextSecondary)
            )
            .font(.appBody(16))
            .foregroundStyle(Color.appTextPrimary)
            .tint(Color.appPrimary)
            .autocorrectionDisabled()

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    AppIconView(icon: .close, size: 16)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Capsule().fill(Color.appSurfaceCard))
        .overlay(Capsule().stroke(Color.appOutline, lineWidth: 1))
    }
}

#Preview {
    @Previewable @State var query = ""
    CommunitySearchField(query: $query)
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

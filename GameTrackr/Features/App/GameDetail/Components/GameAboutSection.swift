import SwiftUI

struct GameAboutSection: View {
    let about: String
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GameSectionHeader(title: "About")

            VStack(alignment: .leading, spacing: 12) {
                Text(about)
                    .font(.appBody(15))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineSpacing(4)
                    .lineLimit(expanded ? nil : 3)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
                } label: {
                    HStack(spacing: 4) {
                        Text(expanded ? "Read less" : "Read more")
                            .font(.appLabel(14))
                        AppIconView(icon: .caretDown, size: 12)
                            .rotationEffect(.degrees(expanded ? 180 : 0))
                    }
                    .foregroundStyle(Color.appSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appSurfaceCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }
}

import SwiftUI

struct StatsSectionCard<Content: View>: View {
    let title: String
    let icon: AppIcon
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.appHeadline(22, weight: .heavy))
                    .foregroundStyle(Color.appTextPrimary)

                Spacer(minLength: 12)

                AppIconView(icon: icon, size: 22)
                    .foregroundStyle(Color.appSecondary)
            }

            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
    }
}

#Preview {
    StatsSectionCard(title: "By status", icon: .chart) {
        Text("Content")
            .foregroundStyle(Color.appTextSecondary)
    }
    .padding(20)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

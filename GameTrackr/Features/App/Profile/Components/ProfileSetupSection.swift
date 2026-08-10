import SwiftUI

struct ProfileSetupSection: View {
    let setups: [SetupItem]
    var onSelect: (SetupItem) -> Void = { _ in }
    var onAdd: () -> Void = {}

    var body: some View {
        if setups.isEmpty {
            emptyCard
        } else {
            carousel
        }
    }

    private var carousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 14) {
                ForEach(setups) { item in
                    Button { onSelect(item) } label: {
                        card(item)
                    }
                    .buttonStyle(PressableButtonStyle())
                }

                Button(action: onAdd) {
                    addCard
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Add setup")
            }
            .padding(.horizontal, 20)
        }
    }

    private func card(_ item: SetupItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SetupCover(setup: item)
                .frame(width: 160, height: 120)

            Text(item.title)
                .font(.appLabel(14))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)

            Text(item.description)
                .font(.appBody(12))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 160, alignment: .leading)
        .contentShape(Rectangle())
    }

    private var addCard: some View {
        VStack(spacing: 8) {
            AppIconView(icon: .plus, size: 24)
                .foregroundStyle(Color.appPrimary)

            Text("Add setup")
                .font(.appBody(13))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(width: 160, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.appOutline, style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
        )
        .contentShape(Rectangle())
    }

    private var emptyCard: some View {
        Button(action: onAdd) {
            HStack(spacing: 14) {
                AppIconView(icon: .devices, size: 26)
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.appPrimary.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("No setup yet")
                        .font(.appLabel(15))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Add photos of your battle station, retro corner or handheld gear.")
                        .font(.appBody(13))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                AppIconView(icon: .plus, size: 18)
                    .foregroundStyle(Color.appPrimary)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.appSurfaceCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.appOutline, style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.horizontal, 20)
    }
}

#Preview("With setups") {
    ProfileSetupSection(setups: ProfileMockData.setups)
        .padding(.vertical, 20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

#Preview("Empty") {
    ProfileSetupSection(setups: [])
        .padding(.vertical, 20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

import SwiftUI

struct MySetupView: View {
    @Binding var setups: [SetupItem]

    @Environment(\.dismiss) private var dismiss
    @State private var draft: SetupItem?

    var body: some View {
        VStack(spacing: 0) {
            header

            if setups.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(item: $draft) { item in
            EditSetupView(
                setup: item,
                isNew: !setups.contains { $0.id == item.id },
                onSave: save,
                onDelete: delete
            )
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
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

            if !setups.isEmpty {
                Button(action: startNewSetup) {
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

    private var emptyState: some View {
        CommunityEmptyState(
            icon: .devices,
            title: "No setup yet",
            message: "Add your battle station, retro corner or handheld gear so other players can see how you play.",
            actionTitle: "Add your first setup",
            action: startNewSetup
        )
        .padding(.bottom, 60)
        .frame(maxHeight: .infinity)
    }

    private var list: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                ForEach(setups) { setup in
                    Button { draft = setup } label: {
                        card(setup)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
    }

    private func card(_ setup: SetupItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SetupCover(setup: setup, cornerRadius: 16, placeholderSize: 48)
                .frame(height: 180)

            VStack(alignment: .leading, spacing: 4) {
                Text(setup.title)
                    .font(.appHeadline(18))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                if !setup.description.isEmpty {
                    Text(setup.description)
                        .font(.appBody(14))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
        .contentShape(Rectangle())
    }

    private func startNewSetup() {
        let palettes = AvatarPalette.allCases
        draft = SetupItem(
            title: "",
            description: "",
            palette: palettes[setups.count % palettes.count]
        )
    }

    private func save(_ setup: SetupItem) {
        if let index = setups.firstIndex(where: { $0.id == setup.id }) {
            setups[index] = setup
        } else {
            setups.append(setup)
        }
    }

    private func delete(_ setup: SetupItem) {
        setups.removeAll { $0.id == setup.id }
    }
}

#Preview("With setups") {
    @Previewable @State var setups = ProfileMockData.setups
    NavigationStack {
        MySetupView(setups: $setups)
    }
    .preferredColorScheme(.dark)
}

#Preview("Empty") {
    @Previewable @State var setups: [SetupItem] = []
    NavigationStack {
        MySetupView(setups: $setups)
    }
    .preferredColorScheme(.dark)
}

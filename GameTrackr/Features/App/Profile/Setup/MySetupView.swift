import SwiftUI

struct MySetupView: View {
    let viewModel: MySetupViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var editing: SetupEditing?

    var body: some View {
        VStack(spacing: 0) {
            MySetupHeader(showAdd: !viewModel.setups.isEmpty, onBack: { dismiss() }, onAdd: startNewSetup)

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(item: $editing) { editing in
            EditSetupView(
                setup: editing.setup,
                onSaved: viewModel.onSetupSaved,
                onDeleted: viewModel.onSetupDeleted
            )
        }
    }

    @ViewBuilder
    private var content: some View {
        if !viewModel.setups.isEmpty {
            list
        } else if viewModel.isLoading {
            ProgressView()
                .tint(Color.appPrimary)
                .frame(maxHeight: .infinity)
        } else if viewModel.hasError {
            EmptyState(
                icon: .info,
                title: "Couldn't load your setups",
                message: "Check your connection and try again.",
                actionTitle: "Try again",
                onAction: { Task { await viewModel.load() } }
            )
            .frame(maxHeight: .infinity)
        } else {
            EmptyState(
                icon: .devices,
                title: "No setup yet",
                message: "Add your battle station, retro corner or handheld gear "
                    + "so other players can see how you play.",
                actionTitle: "Add your first setup",
                onAction: startNewSetup
            )
            .frame(maxHeight: .infinity)
        }
    }

    private var list: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                ForEach(viewModel.setups) { setup in
                    SetupCard(setup: setup) { editing = SetupEditing(setup: setup) }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
    }

    private func startNewSetup() {
        editing = SetupEditing(setup: nil)
    }
}

private struct SetupEditing: Identifiable {
    let id = UUID()
    let setup: SetupItem?
}

#Preview("With setups") {
    @Previewable @State var viewModel = MySetupViewModel(repository: FakeSetupRepository())
    NavigationStack {
        MySetupView(viewModel: viewModel)
    }
    .task { await viewModel.load() }
    .preferredColorScheme(.dark)
}

#Preview("Empty") {
    NavigationStack {
        MySetupView(viewModel: MySetupViewModel(repository: FakeSetupRepository(setups: [])))
    }
    .preferredColorScheme(.dark)
}

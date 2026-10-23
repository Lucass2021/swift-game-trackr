import SwiftUI

struct AddToLibrarySheet: View {
    @Bindable var viewModel: AddToLibraryViewModel
    let onSaved: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            AddToLibraryHeader(
                gameTitle: viewModel.game.title,
                coverStart: viewModel.game.coverStart,
                coverEnd: viewModel.game.coverEnd
            )
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.lg)

            AddToLibraryForm(viewModel: viewModel)

            PrimaryButton(title: "Save to library", isLoading: viewModel.isSaving, icon: .addToLibrary) {
                Task { await viewModel.onSave() }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(Color.appBackground)
        }
        .background(Color.appBackground)
        .toast(message: $viewModel.toastMessage)
        .interactiveDismissDisabled(viewModel.isSaving)
        .onChange(of: viewModel.isSaved) { _, isSaved in
            if isSaved { onSaved() }
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }
}

#Preview {
    Color.appBackground
        .sheet(isPresented: .constant(true)) {
            AddToLibrarySheet(
                viewModel: AddToLibraryViewModel(
                    slug: "neon-ascent-revival",
                    game: FakeGameRepository.gameDetail,
                    repository: FakeLibraryRepository(),
                    libraryUpdates: LibraryUpdates()
                ),
                onSaved: {}
            )
        }
        .preferredColorScheme(.dark)
}

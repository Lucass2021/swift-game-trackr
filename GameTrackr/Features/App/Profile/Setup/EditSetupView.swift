import PhotosUI
import SwiftUI

struct EditSetupView: View {
    let onSaved: (SetupItem) -> Void
    let onDeleted: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: EditSetupViewModel
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var isImporting = false
    @State private var showDeleteConfirm = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case title
        case description
    }

    init(
        setup: SetupItem?,
        repository: SetupRepository = RemoteSetupRepository(),
        onSaved: @escaping (SetupItem) -> Void,
        onDeleted: @escaping (Int) -> Void
    ) {
        self.onSaved = onSaved
        self.onDeleted = onDeleted
        _viewModel = State(initialValue: EditSetupViewModel(setup: setup, repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            EditSetupHeader(
                isNew: viewModel.isNew,
                isSaving: viewModel.isSaving,
                onClose: close,
                onSave: save
            )
            form
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toast(message: $viewModel.errorMessage)
        .onChange(of: pickerItems) { _, items in
            guard !items.isEmpty else { return }
            Task { await importPhotos(items) }
        }
        .alert("Delete this setup?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive, action: delete)
        } message: {
            Text("The photos you added will be removed too.")
        }
    }

    private var form: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                SetupFormField(label: "Photos", counter: "\(viewModel.photoCount)/\(EditSetupViewModel.photoLimit)") {
                    SetupPhotoStrip(
                        images: viewModel.images,
                        newPhotos: viewModel.newPhotos,
                        remainingSlots: viewModel.remainingPhotoSlots,
                        isImporting: isImporting,
                        pickerItems: $pickerItems,
                        onRemoveImage: viewModel.onRemoveImage,
                        onRemoveNewPhoto: viewModel.onRemoveNewPhoto
                    )
                }

                SetupFormField(label: "Title", error: viewModel.titleError) {
                    SetupTextField(text: $viewModel.title, placeholder: "Main Battle Station")
                        .focused($focusedField, equals: .title)
                        .onSubmit { focusedField = .description }
                }

                SetupFormField(label: "Description", error: viewModel.descriptionError) {
                    SetupTextField(
                        text: $viewModel.description,
                        placeholder: "What's in it? Console, monitor, chair, cables...",
                        isMultiline: true
                    )
                    .focused($focusedField, equals: .description)
                }

                if !viewModel.isNew {
                    SetupDeleteButton(isDeleting: viewModel.isDeleting) { showDeleteConfirm = true }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func importPhotos(_ items: [PhotosPickerItem]) async {
        isImporting = true
        defer {
            isImporting = false
            pickerItems = []
        }

        var photos: [SetupPhoto] = []
        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let photo = SetupPhoto.downsampled(from: data, sourceId: item.itemIdentifier)
            else { continue }
            photos.append(photo)
        }
        viewModel.onPhotosPicked(photos)
    }

    private func close() {
        guard !viewModel.isBusy else { return }
        dismiss()
    }

    private func save() {
        focusedField = nil
        Task {
            guard let saved = await viewModel.save() else { return }
            onSaved(saved)
            dismiss()
        }
    }

    private func delete() {
        Task {
            guard let id = await viewModel.delete() else { return }
            onDeleted(id)
            dismiss()
        }
    }
}

#Preview {
    EditSetupView(
        setup: ProfileMockData.setups[0],
        repository: FakeSetupRepository(),
        onSaved: { _ in },
        onDeleted: { _ in }
    )
    .preferredColorScheme(.dark)
}

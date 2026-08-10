import PhotosUI
import SwiftUI

struct EditSetupView: View {
    let isNew: Bool
    let onSave: (SetupItem) -> Void
    let onDelete: (SetupItem) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var setup: SetupItem
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var isImporting = false
    @State private var showDeleteConfirm = false
    @FocusState private var focusedField: Field?

    private static let photoLimit = 6

    private enum Field {
        case title
        case description
    }

    init(
        setup: SetupItem,
        isNew: Bool,
        onSave: @escaping (SetupItem) -> Void,
        onDelete: @escaping (SetupItem) -> Void
    ) {
        self.isNew = isNew
        self.onSave = onSave
        self.onDelete = onDelete
        _setup = State(initialValue: setup)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            form
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .onChange(of: pickerItems) { _, items in
            guard !items.isEmpty else { return }
            Task { await importPhotos(items) }
        }
        .alert("Delete this setup?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete(setup)
                dismiss()
            }
        } message: {
            Text("The photos you added will be removed too.")
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                AppIconView(icon: .close, size: 20)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Close")

            Text(isNew ? "New setup" : "Edit setup")
                .font(.appHeadline(20))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Button(action: save) {
                Text("Save")
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, 20)
                    .frame(height: 38)
                    .background(Capsule().fill(Color.appPrimary))
                    .opacity(canSave ? 1 : 0.45)
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(!canSave)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var form: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                photosField

                field("Title") {
                    TextField(
                        "",
                        text: $setup.title,
                        prompt: Text("Main Battle Station")
                            .foregroundStyle(Color.appTextSecondary)
                    )
                    .font(.appBody(16))
                    .foregroundStyle(Color.appTextPrimary)
                    .tint(Color.appPrimary)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .title)
                    .onSubmit { focusedField = .description }
                    .fieldBox()
                }

                field("Description") {
                    TextField(
                        "",
                        text: $setup.description,
                        prompt: Text("What's in it? Console, monitor, chair, cables...")
                            .foregroundStyle(Color.appTextSecondary),
                        axis: .vertical
                    )
                    .font(.appBody(16))
                    .foregroundStyle(Color.appTextPrimary)
                    .tint(Color.appPrimary)
                    .lineLimit(3 ... 6)
                    .focused($focusedField, equals: .description)
                    .padding(14)
                    .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.appSurfaceCard)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.appOutline, lineWidth: 1)
                    )
                }

                if !isNew {
                    Button { showDeleteConfirm = true } label: {
                        HStack(spacing: 10) {
                            AppIconView(icon: .trash, size: 18)
                            Text("Delete setup")
                                .font(.appLabel(16))
                        }
                        .foregroundStyle(Color.appTertiary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.appTertiary.opacity(0.4), lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var photosField: some View {
        field("Photos", counter: "\(setup.photos.count)/\(Self.photoLimit)") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(setup.photos) { photo in
                        thumbnail(photo)
                    }

                    if setup.photos.count < Self.photoLimit {
                        addPhotoTile
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func thumbnail(_ photo: SetupPhoto) -> some View {
        Image(uiImage: photo.image)
            .resizable()
            .scaledToFill()
            .frame(width: 108, height: 108)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(alignment: .topTrailing) {
                Button { remove(photo) } label: {
                    AppIconView(icon: .close, size: 12)
                        .foregroundStyle(Color.white)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.black.opacity(0.6)))
                        .contentShape(Circle())
                }
                .buttonStyle(PressableButtonStyle())
                .padding(6)
                .accessibilityLabel("Remove photo")
            }
    }

    private var addPhotoTile: some View {
        PhotosPicker(
            selection: $pickerItems,
            maxSelectionCount: Self.photoLimit - setup.photos.count,
            matching: .images,
            photoLibrary: .shared()
        ) {
            VStack(spacing: 8) {
                if isImporting {
                    ProgressView()
                        .tint(Color.appPrimary)
                } else {
                    AppIconView(icon: .plus, size: 22)
                        .foregroundStyle(Color.appPrimary)

                    Text("Add photo")
                        .font(.appBody(12))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .frame(width: 108, height: 108)
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
        .disabled(isImporting)
    }

    private var canSave: Bool {
        !setup.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func field(
        _ label: String,
        counter: String? = nil,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionLabel(text: label)
                Spacer()
                if let counter {
                    Text(counter)
                        .font(.appBody(12))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func importPhotos(_ items: [PhotosPickerItem]) async {
        isImporting = true
        defer {
            isImporting = false
            pickerItems = []
        }

        for item in items {
            guard setup.photos.count < Self.photoLimit else { break }
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let photo = SetupPhoto.downsampled(from: data)
            else { continue }
            setup.photos.append(photo)
        }
    }

    private func remove(_ photo: SetupPhoto) {
        setup.photos.removeAll { $0.id == photo.id }
    }

    private func save() {
        focusedField = nil
        setup.title = setup.title.trimmingCharacters(in: .whitespacesAndNewlines)
        setup.description = setup.description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard canSave else { return }
        onSave(setup)
        dismiss()
    }
}

#Preview {
    EditSetupView(
        setup: SetupItem(title: "", description: ""),
        isNew: true,
        onSave: { _ in },
        onDelete: { _ in }
    )
    .preferredColorScheme(.dark)
}

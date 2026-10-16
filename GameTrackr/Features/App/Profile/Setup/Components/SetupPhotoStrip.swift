import PhotosUI
import SwiftUI

struct SetupPhotoStrip: View {
    private static let thumbnailSize: CGFloat = 108

    let images: [SetupImage]
    let newPhotos: [SetupPhoto]
    let remainingSlots: Int
    let isImporting: Bool
    @Binding var pickerItems: [PhotosPickerItem]
    let onRemoveImage: (Int) -> Void
    let onRemoveNewPhoto: (SetupPhoto) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(images) { image in
                    thumbnail { remoteImage(image) } onRemove: { onRemoveImage(image.id) }
                }

                ForEach(newPhotos) { photo in
                    thumbnail {
                        Image(uiImage: photo.image)
                            .resizable()
                            .scaledToFill()
                    } onRemove: { onRemoveNewPhoto(photo) }
                }

                if remainingSlots > 0 {
                    addPhotoTile
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func remoteImage(_ image: SetupImage) -> some View {
        AsyncImage(url: URL(string: image.url)) { loaded in
            loaded
                .resizable()
                .scaledToFill()
        } placeholder: {
            Color.appSurfaceCard
        }
    }

    private func thumbnail(
        @ViewBuilder content: () -> some View,
        onRemove: @escaping () -> Void
    ) -> some View {
        content()
            .frame(width: Self.thumbnailSize, height: Self.thumbnailSize)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(alignment: .topTrailing) {
                Button(action: onRemove) {
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
            maxSelectionCount: remainingSlots,
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
            .frame(width: Self.thumbnailSize, height: Self.thumbnailSize)
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
}

#Preview {
    SetupPhotoStrip(
        images: [],
        newPhotos: [],
        remainingSlots: EditSetupViewModel.photoLimit,
        isImporting: false,
        pickerItems: .constant([]),
        onRemoveImage: { _ in },
        onRemoveNewPhoto: { _ in }
    )
    .padding(20)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

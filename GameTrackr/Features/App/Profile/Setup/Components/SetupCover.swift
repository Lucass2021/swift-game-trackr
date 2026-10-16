import SwiftUI

struct SetupCover: View {
    let setup: SetupItem
    var cornerRadius: CGFloat = 14
    var placeholderSize: CGFloat = 38

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    var body: some View {
        shape
            .fill(
                LinearGradient(
                    colors: [setup.palette.start, setup.palette.end],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                if let cover = setup.images.first, let url = URL(string: cover.url) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.clear
                    }
                } else {
                    AppIconView(icon: .devices, size: placeholderSize)
                        .foregroundStyle(Color.white.opacity(0.22))
                }
            }
            .clipShape(shape)
            .overlay(shape.stroke(Color.appOutline, lineWidth: 1))
            .overlay(alignment: .topTrailing) {
                if setup.images.count > 1 {
                    photoCount
                }
            }
    }

    private var photoCount: some View {
        HStack(spacing: 4) {
            AppIconView(icon: .grid, size: 11)
            Text("\(setup.images.count)")
                .font(.appLabel(11))
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.black.opacity(0.55)))
        .padding(8)
    }
}

#Preview {
    SetupCover(setup: ProfileMockData.setups[1])
        .frame(width: 200, height: 130)
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

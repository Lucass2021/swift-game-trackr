import SwiftUI

struct GameCoverArt: View {
    let start: Color
    let end: Color
    var url: String?
    var width: CGFloat?
    var height: CGFloat?

    private let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)

    private var brandSize: CGFloat {
        if let width, let height {
            return min(width, height) * 0.32
        }
        return 44
    }

    private var imageURL: URL? {
        url.flatMap(URL.init(string:))
    }

    var body: some View {
        Color.clear
            .overlay { cover }
            .frame(width: width, height: height)
            .clipShape(shape)
            .overlay {
                shape.stroke(Color.appOutline, lineWidth: 1)
            }
    }

    @ViewBuilder
    private var cover: some View {
        if let imageURL {
            AsyncImage(url: imageURL, transaction: Transaction(animation: .easeOut(duration: 0.2))) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    missingArtwork
                default:
                    skeleton
                }
            }
        } else {
            missingArtwork
        }
    }

    private var skeleton: some View {
        Color.appSurfaceCard
    }

    private var missingArtwork: some View {
        LinearGradient(
            colors: [start, end],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            AppIconView(icon: .brand, size: brandSize)
                .foregroundStyle(Color.white.opacity(0.18))
        }
    }
}

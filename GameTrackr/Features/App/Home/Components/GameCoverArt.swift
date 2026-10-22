import SwiftUI

private enum Constants {
    static let brandSize: CGFloat = 44
    static let brandRatio: CGFloat = 0.32
    static let brandOpacity = 0.18
    static let borderWidth: CGFloat = 1
    static let previewWidth: CGFloat = 150
    static let previewHeight: CGFloat = 200
}

struct GameCoverArt: View {
    let start: Color
    let end: Color
    var url: String?
    var width: CGFloat?
    var height: CGFloat?

    private let shape = RoundedRectangle(cornerRadius: Radius.md, style: .continuous)

    private var brandSize: CGFloat {
        if let width, let height {
            return min(width, height) * Constants.brandRatio
        }
        return Constants.brandSize
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
                shape.stroke(Color.appOutline, lineWidth: Constants.borderWidth)
            }
    }

    @ViewBuilder
    private var cover: some View {
        if let imageURL {
            AsyncImage(
                url: imageURL,
                transaction: Transaction(animation: .easeOut(duration: Durations.short))
            ) { phase in
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
                .foregroundStyle(Color.white.opacity(Constants.brandOpacity))
        }
    }
}

#Preview {
    GameCoverArt(
        start: .coverVioletStart,
        end: .coverVioletEnd,
        width: Constants.previewWidth,
        height: Constants.previewHeight
    )
    .padding(Spacing.lg)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

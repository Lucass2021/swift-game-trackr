import SwiftUI

private enum Constants {
    static let aspectRatio: CGFloat = 16 / 9
    static let iconSize: CGFloat = 44
    static let iconAlpha = 0.15
    static let borderWidth: CGFloat = 1
}

struct PostDetailMedia: View {
    let post: CommunityPost

    var body: some View {
        RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [post.mediaStart, post.mediaEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(Constants.aspectRatio, contentMode: .fit)
            .overlay {
                AppIconView(icon: .brand, size: Constants.iconSize)
                    .foregroundStyle(Color.appTextPrimary.opacity(Constants.iconAlpha))
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
            }
    }
}

#Preview {
    PostDetailMedia(post: CommunityMockData.detailPost)
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

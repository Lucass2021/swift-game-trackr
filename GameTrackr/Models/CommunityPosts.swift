extension [CommunityPost] {
    func prependingPost(_ post: CommunityPost) -> [CommunityPost] {
        [post] + filter { $0.id != post.id }
    }
}

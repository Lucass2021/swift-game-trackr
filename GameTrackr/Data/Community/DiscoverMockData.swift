enum DiscoverMockData {
    static let mockIdOffset = 1_000_000

    static let categoryCommunities: [Community] = CommunityMockData.all.map { community in
        Community(
            id: community.id + mockIdOffset,
            name: community.name,
            authorId: community.authorId,
            category: community.category,
            memberCount: community.memberCount,
            postCount: community.postCount,
            online: community.online,
            description: community.description,
            isJoined: community.isJoined,
            avatarUrl: community.avatarUrl,
            coverUrl: community.coverUrl,
            iconStart: community.iconStart,
            iconEnd: community.iconEnd,
            createdMonth: community.createdMonth
        )
    }
}

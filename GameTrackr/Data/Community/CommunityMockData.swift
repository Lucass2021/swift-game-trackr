import Foundation

nonisolated enum CommunityMockData {
    static let suggested = Community(
        id: 201,
        name: "RPG Speedrunners",
        category: "RPG",
        memberCount: 12400,
        postCount: 340,
        online: "89",
        description: "The ultimate hub for breaking world records in classic and modern RPGs.",
        isJoined: false,
        icon: .emerald
    )

    static let featured: [Community] = [
        Community(
            id: 202,
            name: "Elden Ring Lore",
            category: "RPG",
            memberCount: 8200,
            postCount: 412,
            online: "120",
            description: "Theories, item descriptions and everything the Lands Between refuse to explain.",
            isJoined: false,
            icon: .emerald
        ),
        Community(
            id: 203,
            name: "Retro Vault",
            category: "Retro",
            memberCount: 12000,
            postCount: 980,
            online: "203",
            description: "Cartridges, CRTs and high scores. Nostalgia lives here.",
            isJoined: false,
            icon: .crimson
        ),
        Community(
            id: 204,
            name: "Indie Gems Only",
            category: "Indie",
            memberCount: 8900,
            postCount: 255,
            online: "64",
            description: "Discovery platform for the little games with the biggest ideas.",
            isJoined: false,
            icon: .violet
        )
    ]

    static let all: [Community] = [
        Community(
            id: 205,
            name: "Final Fantasy VII Rebirth",
            category: "RPG",
            memberCount: 12400,
            postCount: 530,
            online: "142",
            description: "Sharing the best builds, materia setups and side quest routes.",
            isJoined: true,
            icon: .indigo
        ),
        Community(
            id: 206,
            name: "Valorant Tactics",
            category: "FPS",
            memberCount: 45200,
            postCount: 2100,
            online: "870",
            description: "The ultimate community for lineups, agent picks and ranked climbing.",
            isJoined: false,
            icon: .crimson
        ),
        Community(
            id: 204,
            name: "Indie Gems Only",
            category: "Indie",
            memberCount: 8900,
            postCount: 255,
            online: "64",
            description: "Discovery platform for the little games with the biggest ideas.",
            isJoined: false,
            icon: .violet
        ),
        Community(
            id: 207,
            name: "PC Modding Lab",
            category: "Tech",
            memberCount: 22100,
            postCount: 1400,
            online: "310",
            description: "Advanced techniques for hardware tuning, shaders and texture packs.",
            isJoined: false,
            icon: .pine
        ),
        Community(
            id: 208,
            name: "Speedrun Central",
            category: "Speedrun",
            memberCount: 15300,
            postCount: 770,
            online: "198",
            description: "Frame-perfect tricks, glitch hunting and world record splits.",
            isJoined: true,
            icon: .azure
        )
    ]

    static let detailCommunity = Community(
        id: 201,
        name: "RPG Speedrunners",
        category: "RPG",
        memberCount: 12400,
        postCount: 340,
        online: "89",
        description: "The ultimate hub for breaking world records in classic and modern RPGs. Share your routes, " +
            "discuss glitch hunting techniques, and compare splits with the fastest players around.",
        isJoined: false,
        icon: .emerald,
        createdMonth: "March 2024"
    )

    static let members: [CommunityMember] = [
        CommunityMember(
            id: 401,
            author: "@ShadowReaper",
            role: "Moderator",
            avatar: .violet,
            username: "shadowreaper"
        ),
        CommunityMember(
            id: 402,
            author: "@chrono_runner",
            role: "Moderator",
            avatar: .azure,
            username: "chrono_runner"
        ),
        CommunityMember(
            id: 403,
            author: "@QuestMaster",
            role: "Member · joined 2 months ago",
            avatar: .emerald,
            username: "questmaster"
        ),
        CommunityMember(
            id: 404,
            author: "@VoidWalker",
            role: "Member · joined 5 months ago",
            avatar: .crimson,
            username: "voidwalker"
        ),
        CommunityMember(
            id: 405,
            author: "@NeonSamurai",
            role: "Member · joined 1 year ago",
            avatar: .cyan,
            username: "neonsamurai"
        )
    ]
}

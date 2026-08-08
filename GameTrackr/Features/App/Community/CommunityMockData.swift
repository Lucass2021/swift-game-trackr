import SwiftUI

enum CommunityMockData {
    static let feed: [CommunityPost] = [
        CommunityPost(
            id: 101,
            author: "@ShadowReaper",
            timeAgo: "2h ago",
            communityName: "RPG Speedrunners",
            title: "Finally hit Platinum on Elden Ring!",
            preview: "After 200+ hours and countless deaths to Malenia, I finally managed to secure the last trophy " +
                "of the run.",
            likes: 1204,
            comments: 84,
            hasMedia: true,
            isLiked: true,
            avatarStart: .coverVioletStart,
            avatarEnd: .coverVioletEnd,
            mediaStart: .coverEmeraldStart,
            mediaEnd: .coverEmeraldEnd
        ),
        CommunityPost(
            id: 102,
            author: "@PixelWitcher",
            timeAgo: "5h ago",
            communityName: "Cyberpunk Lore",
            title: "New Night City secrets discovered",
            preview: "The latest patch hid some new QR codes in the Kabuki market area. Has anyone else managed to " +
                "decode them?",
            likes: 2401,
            comments: 312,
            hasMedia: true,
            avatarStart: .coverPineStart,
            avatarEnd: .coverPineEnd,
            mediaStart: .coverIndigoStart,
            mediaEnd: .coverIndigoEnd
        ),
        CommunityPost(
            id: 103,
            author: "@RetroGamer",
            timeAgo: "8h ago",
            communityName: "Retro Vault",
            title: "Is the new DLC worth it?",
            preview: "A few hours in and here are my first impressions. The new map is massive and the combat " +
                "finally feels tight.",
            likes: 85,
            comments: 12,
            hasMedia: false,
            avatarStart: .coverAzureStart,
            avatarEnd: .coverAzureEnd,
            mediaStart: .coverCyanStart,
            mediaEnd: .coverCyanEnd
        )
    ]

    static let suggested = Community(
        id: 201,
        name: "RPG Speedrunners",
        category: "RPG",
        memberCount: 12400,
        postCount: 340,
        online: "89",
        description: "The ultimate hub for breaking world records in classic and modern RPGs.",
        isJoined: false,
        iconStart: .coverEmeraldStart,
        iconEnd: .coverEmeraldEnd
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
            iconStart: .coverEmeraldStart,
            iconEnd: .coverEmeraldEnd
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
            iconStart: .coverCrimsonStart,
            iconEnd: .coverCrimsonEnd
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
            iconStart: .coverVioletStart,
            iconEnd: .coverVioletEnd
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
            iconStart: .coverIndigoStart,
            iconEnd: .coverIndigoEnd
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
            iconStart: .coverCrimsonStart,
            iconEnd: .coverCrimsonEnd
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
            iconStart: .coverVioletStart,
            iconEnd: .coverVioletEnd
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
            iconStart: .coverPineStart,
            iconEnd: .coverPineEnd
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
            iconStart: .coverAzureStart,
            iconEnd: .coverAzureEnd
        )
    ]

    static let categories = ["All", "RPG", "FPS", "Indie", "Retro", "Speedrun", "Tech"]

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
        iconStart: .coverEmeraldStart,
        iconEnd: .coverEmeraldEnd
    )

    static let communityPosts: [CommunityPost] = [
        CommunityPost(
            id: 104,
            author: "@chrono_runner",
            timeAgo: "2h ago",
            communityName: "RPG Speedrunners",
            title: "New glitch found in Chrono Trigger's 1999 AD sequence!",
            preview: "Testing out the latest route for the 100% run and stumbled across a frame-perfect warp that " +
                "skips the whole tower.",
            likes: 432,
            comments: 24,
            hasMedia: true,
            avatarStart: .coverAzureStart,
            avatarEnd: .coverAzureEnd,
            mediaStart: .coverPineStart,
            mediaEnd: .coverPineEnd
        ),
        CommunityPost(
            id: 105,
            author: "@master_of_none",
            timeAgo: "5h ago",
            communityName: "RPG Speedrunners",
            title: "Weekly challenge: barebones level 1 boss rush",
            preview: "This week we're tackling the main story bosses without any equipment upgrades. Post your " +
                "splits below.",
            likes: 1204,
            comments: 156,
            hasMedia: false,
            avatarStart: .coverCrimsonStart,
            avatarEnd: .coverCrimsonEnd,
            mediaStart: .coverCyanStart,
            mediaEnd: .coverCyanEnd
        )
    ]

    static let detailPost = CommunityPost(
        id: 106,
        author: "@ShadowReaper",
        timeAgo: "Posted on March 14, 2024",
        communityName: "RPG Speedrunners",
        title: "The state of RPGs in 2024: is the golden age back?",
        preview: "After decades of chasing cinematic realism, developers are finally pivoting back to deep " +
            "mechanical complexity. We're seeing a massive resurgence in turn-based systems and intricate " +
            "skill trees that actually matter.",
        likes: 1204,
        comments: 24,
        hasMedia: true,
        isLiked: true,
        avatarStart: .coverVioletStart,
        avatarEnd: .coverVioletEnd,
        mediaStart: .coverIndigoStart,
        mediaEnd: .coverIndigoEnd
    )

    static let detailPostHighlights = [
        "Emergent narrative choices that ripple through entire campaigns.",
        "Performance optimizations hitting 120FPS on baseline consoles.",
        "Modular difficulty settings catering to both casual and hardcore speedrunners."
    ]

    static let comments: [PostComment] = [
        PostComment(
            id: 301,
            author: "@QuestMaster",
            timeAgo: "2h",
            content: "I absolutely agree. The resurgence of CRPGs specifically has been a breath of fresh air. 2024 " +
                "is looking like a legendary year for build variety.",
            likes: 12,
            avatarStart: .coverVioletStart,
            avatarEnd: .coverVioletEnd,
            replies: [
                PostComment(
                    id: 302,
                    author: "@LootGoblin",
                    timeAgo: "1h",
                    content: "Specifically the combat mechanics in the latest release — they finally got the balance " +
                        "right!",
                    likes: 5,
                    avatarStart: .coverEmeraldStart,
                    avatarEnd: .coverEmeraldEnd
                )
            ],
            hiddenReplies: 3
        ),
        PostComment(
            id: 303,
            author: "@VoidWalker",
            timeAgo: "5h",
            content: "The inventory management is still a mess though. No matter how deep the story is, if the UI is " +
                "clunky the experience suffers.",
            likes: 8,
            avatarStart: .coverAzureStart,
            avatarEnd: .coverAzureEnd
        ),
        PostComment(
            id: 304,
            author: "@NeonSamurai",
            timeAgo: "7h",
            content: "Turn-based is back and I could not be happier. Give me a menu and a damage formula over " +
                "another cinematic set piece.",
            likes: 21,
            isLiked: true,
            avatarStart: .coverCrimsonStart,
            avatarEnd: .coverCrimsonEnd
        )
    ]

    static let members: [CommunityMember] = [
        CommunityMember(
            id: 401,
            author: "@ShadowReaper",
            role: "Moderator",
            avatarStart: .coverVioletStart,
            avatarEnd: .coverVioletEnd
        ),
        CommunityMember(
            id: 402,
            author: "@chrono_runner",
            role: "Moderator",
            avatarStart: .coverAzureStart,
            avatarEnd: .coverAzureEnd
        ),
        CommunityMember(
            id: 403,
            author: "@QuestMaster",
            role: "Member · joined 2 months ago",
            avatarStart: .coverEmeraldStart,
            avatarEnd: .coverEmeraldEnd
        ),
        CommunityMember(
            id: 404,
            author: "@VoidWalker",
            role: "Member · joined 5 months ago",
            avatarStart: .coverCrimsonStart,
            avatarEnd: .coverCrimsonEnd
        ),
        CommunityMember(
            id: 405,
            author: "@NeonSamurai",
            role: "Member · joined 1 year ago",
            avatarStart: .coverCyanStart,
            avatarEnd: .coverCyanEnd
        )
    ]

    static let quickReactions = ["❤️", "🙌", "🔥", "👏", "😢", "😍"]
}

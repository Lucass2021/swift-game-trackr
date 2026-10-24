enum HelpFaq: CaseIterable, Hashable {
    case addGame
    case playtime
    case friends
    case privacy

    var question: String {
        switch self {
        case .addGame: "How do I add a game to my library?"
        case .playtime: "Can I track my playtime?"
        case .friends: "How do I connect with friends?"
        case .privacy: "Is my data private?"
        }
    }

    var answer: String {
        switch self {
        case .addGame:
            "Search for a game using the search bar, open its detail page, and tap \"Add to library\". "
                + "You can then set a status like playing, completed, or backlog."
        case .playtime:
            "Yes! Open any game in your library and edit its details. You can log hours played, "
                + "start and finish dates, and even write a short review."
        case .friends:
            "Visit another user's profile and send them a friend request. Once they accept, "
                + "you can see each other's library and stats, even on private profiles."
        case .privacy:
            "Your profile is public by default. You can make it private in Edit profile, "
                + "so only friends can see your library and stats."
        }
    }
}

enum ShellRoute: Hashable {
    case search(SearchScope)
    case notifications
    case menu
    case gameDetail(slug: String)
    case stats
    case editProfile
    case mySetup
}

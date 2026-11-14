enum AuthRoute: Hashable {
    case register
    case login
}

func openAuthRoute(_ route: AuthRoute, in path: [AuthRoute]) -> [AuthRoute] {
    guard let index = path.firstIndex(of: route) else { return path + [route] }
    return Array(path.prefix(through: index))
}

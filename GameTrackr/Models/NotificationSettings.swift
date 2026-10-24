nonisolated enum NotificationSetting: CaseIterable {
    case push
    case friendRequests
    case communityReplies
}

nonisolated struct NotificationSettings: Equatable {
    var push = true
    var friendRequests = true
    var communityReplies = true

    func isEnabled(_ setting: NotificationSetting) -> Bool {
        switch setting {
        case .push: push
        case .friendRequests: friendRequests
        case .communityReplies: communityReplies
        }
    }

    func with(_ setting: NotificationSetting, enabled: Bool) -> NotificationSettings {
        var settings = self
        switch setting {
        case .push: settings.push = enabled
        case .friendRequests: settings.friendRequests = enabled
        case .communityReplies: settings.communityReplies = enabled
        }
        return settings
    }
}

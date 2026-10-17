import Foundation

@MainActor
@Observable
final class UserProfileViewModel {
    private(set) var profile: Profile?
    private(set) var overview: ProfileOverview?
    private(set) var isFriend = false
    private(set) var isLoading = false
    private(set) var hasError = false
    var toastMessage: String?

    private let repository: ProfileOverviewRepository
    private let user: UserProfile
    private var loadTask: Task<Void, Never>?
    private var friendTask: Task<Void, Never>?

    init(user: UserProfile, repository: ProfileOverviewRepository) {
        self.user = user
        self.repository = repository
    }

    func loadIfNeeded() async {
        guard overview == nil, !isLoading else { return }
        await load()
    }

    func load() async {
        loadTask?.cancel()
        isLoading = true
        hasError = false
        let task = Task { await fetch() }
        loadTask = task
        await task.value
    }

    func onFriendAction(isGuest: Bool) async {
        guard !isGuest else {
            toastMessage = "You're browsing as a guest. Create an account to add friends."
            return
        }
        let newValue = !isFriend
        isFriend = newValue
        friendTask?.cancel()
        let task = Task { await saveFriend(newValue) }
        friendTask = task
        await task.value
    }

    func onMessage(isGuest: Bool) {
        guard isGuest else { return }
        toastMessage = "You're browsing as a guest. Create an account to send messages."
    }

    private func saveFriend(_ newValue: Bool) async {
        do {
            try await repository.setFriend(username: user.username, isFriend: newValue)
        } catch {
            guard !Task.isCancelled else { return }
            isFriend = !newValue
            toastMessage = "Couldn't update friends. Please try again."
        }
    }

    private func fetch() async {
        do {
            let result = try await repository.fetchUserOverview(username: user.username)
            guard !Task.isCancelled else { return }
            profile = Profile(
                name: user.name,
                username: user.username,
                bio: result.bio,
                joinedAt: result.joinedAt,
                avatarHex: user.avatarStart.hexString
            )
            overview = result.overview
            isFriend = result.isFriend
        } catch {
            guard !Task.isCancelled else { return }
            hasError = true
        }
        isLoading = false
    }
}

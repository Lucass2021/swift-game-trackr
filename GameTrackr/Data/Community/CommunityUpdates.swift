struct CommunityJoin: Equatable {
    let communityId: Int
    let isJoined: Bool
}

@MainActor
final class CommunityUpdates {
    private var observers: [(owner: WeakCommunityObserver, handler: (CommunityJoin) -> Void)] = []

    func observe(_ owner: AnyObject, handler: @escaping (CommunityJoin) -> Void) {
        observers.append((WeakCommunityObserver(owner), handler))
    }

    func publish(communityId: Int, isJoined: Bool) {
        observers.removeAll { $0.owner.value == nil }
        let join = CommunityJoin(communityId: communityId, isJoined: isJoined)
        for observer in observers {
            observer.handler(join)
        }
    }
}

private final class WeakCommunityObserver {
    weak var value: AnyObject?

    init(_ value: AnyObject) {
        self.value = value
    }
}

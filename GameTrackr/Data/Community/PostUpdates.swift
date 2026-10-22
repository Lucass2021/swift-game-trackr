@MainActor
final class PostUpdates {
    private var observers: [(owner: WeakOwner, handler: (CommunityPost) -> Void)] = []

    func observe(_ owner: AnyObject, handler: @escaping (CommunityPost) -> Void) {
        observers.append((WeakOwner(owner), handler))
    }

    func publish(_ post: CommunityPost) {
        observers.removeAll { $0.owner.value == nil }
        for observer in observers {
            observer.handler(post)
        }
    }
}

private final class WeakOwner {
    weak var value: AnyObject?

    init(_ value: AnyObject) {
        self.value = value
    }
}

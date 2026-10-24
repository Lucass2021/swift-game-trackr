@MainActor
final class PostUpdates {
    private var observers: [Observer] = []
    private var createdObservers: [Observer] = []

    func observe(_ owner: AnyObject, handler: @escaping (CommunityPost) -> Void) {
        observers.append((WeakOwner(owner), handler))
    }

    func observeCreated(_ owner: AnyObject, handler: @escaping (CommunityPost) -> Void) {
        createdObservers.append((WeakOwner(owner), handler))
    }

    func publish(_ post: CommunityPost) {
        observers = Self.notify(observers, post)
    }

    func publishCreated(_ post: CommunityPost) {
        createdObservers = Self.notify(createdObservers, post)
    }

    private static func notify(_ observers: [Observer], _ post: CommunityPost) -> [Observer] {
        let alive = observers.filter { $0.owner.value != nil }
        for observer in alive {
            observer.handler(post)
        }
        return alive
    }
}

private typealias Observer = (owner: WeakOwner, handler: (CommunityPost) -> Void)

private final class WeakOwner {
    weak var value: AnyObject?

    init(_ value: AnyObject) {
        self.value = value
    }
}

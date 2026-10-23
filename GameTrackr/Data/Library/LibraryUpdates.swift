@MainActor
final class LibraryUpdates {
    private var observers: [(owner: WeakOwner, handler: (String) -> Void)] = []

    func observe(_ owner: AnyObject, handler: @escaping (String) -> Void) {
        observers.append((WeakOwner(owner), handler))
    }

    func publish(_ slug: String) {
        observers.removeAll { $0.owner.value == nil }
        for observer in observers {
            observer.handler(slug)
        }
    }
}

private final class WeakOwner {
    weak var value: AnyObject?

    init(_ value: AnyObject) {
        self.value = value
    }
}

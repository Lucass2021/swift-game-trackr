import Foundation

@MainActor
@Observable
final class AddToLibraryViewModel: Identifiable {
    private static let maxHoursLength = 5

    let id = UUID()
    let game: GameDetail
    let platforms: [String]
    private(set) var status: LibraryStatus = .playing
    private(set) var rating = 0
    private(set) var hours = ""
    private(set) var platform: String?
    private(set) var startedAt: Date?
    private(set) var finishedAt: Date?
    private(set) var review = ""
    private(set) var isSubmitted = false
    private(set) var isSaving = false
    private(set) var isSaved = false
    var toastMessage: String?

    var dateError: String? {
        guard isSubmitted, let startedAt, let finishedAt, finishedAt < startedAt else { return nil }
        return "The finish date can't be before the start date."
    }

    private let repository: LibraryRepository
    private let libraryUpdates: LibraryUpdates
    private let slug: String

    init(slug: String, game: GameDetail, repository: LibraryRepository, libraryUpdates: LibraryUpdates) {
        self.slug = slug
        self.game = game
        self.repository = repository
        self.libraryUpdates = libraryUpdates
        platforms = game.platforms
        platform = game.platforms.first
    }

    func onStatusChange(_ status: LibraryStatus) {
        self.status = status
    }

    func onRatingChange(_ rating: Int) {
        self.rating = rating
    }

    func onHoursChange(_ hours: String) {
        self.hours = String(hours.filter { $0.isASCII && $0.isNumber }.prefix(Self.maxHoursLength))
    }

    func onPlatformChange(_ platform: String) {
        self.platform = platform
    }

    func onStartedChange(_ date: Date?) {
        startedAt = date
    }

    func onFinishedChange(_ date: Date?) {
        finishedAt = date
    }

    func onReviewChange(_ review: String) {
        self.review = review
    }

    func onSave() async {
        guard !isSaving else { return }
        isSubmitted = true
        guard dateError == nil else { return }
        isSaving = true
        let entry = newEntry()
        let task = Task { await save(entry) }
        await task.value
    }

    private func save(_ entry: NewLibraryEntry) async {
        do {
            try await repository.addToLibrary(entry)
            libraryUpdates.publish(slug)
            isSaved = true
        } catch {
            toastMessage = "Couldn't save to your library. Please try again."
        }
        isSaving = false
    }

    private func newEntry() -> NewLibraryEntry {
        let trimmedReview = review.trimmingCharacters(in: .whitespacesAndNewlines)
        return NewLibraryEntry(
            title: game.title,
            slug: slug,
            status: status,
            rating: rating,
            hours: Int(hours),
            platform: platform,
            startedAt: startedAt,
            finishedAt: finishedAt,
            review: trimmedReview.isEmpty ? nil : trimmedReview,
            coverStart: game.coverStart,
            coverEnd: game.coverEnd
        )
    }
}

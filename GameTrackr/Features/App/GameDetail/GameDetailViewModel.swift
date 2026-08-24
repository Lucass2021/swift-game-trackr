import SwiftUI

@MainActor
@Observable
final class GameDetailViewModel {
    private(set) var game: GameDetail?
    private(set) var isLoading = false
    private(set) var failed = false

    private let service = GameService.shared

    func load(slug: String) async {
        guard !isLoading else { return }
        isLoading = true
        failed = false

        do {
            game = try await GameDetail(dto: service.fetchGame(slug: slug))
        } catch {
            failed = true
        }

        isLoading = false
    }
}

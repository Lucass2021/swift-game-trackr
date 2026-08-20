import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    private(set) var newReleases: [Game] = []
    private(set) var isLoadingNewReleases = false
    private(set) var hasLoadedNewReleases = false
    private(set) var newReleasesError: String?

    private let service = GameService.shared

    func loadNewReleases() async {
        guard !isLoadingNewReleases else { return }
        isLoadingNewReleases = true
        newReleasesError = nil

        do {
            let dtos = try await service.fetchNewReleases(limit: 10)
            newReleases = dtos.map(Game.init(dto:))
        } catch {
            newReleasesError = error.localizedDescription
        }

        isLoadingNewReleases = false
        hasLoadedNewReleases = true
    }
}

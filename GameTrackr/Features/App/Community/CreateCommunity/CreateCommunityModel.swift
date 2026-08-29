import SwiftUI

@MainActor
@Observable
final class CreateCommunityModel {
    static let nameLimit = 255
    static let descriptionLimit = 2000

    var name = ""
    var description = ""
    private(set) var hasAttemptedSubmit = false
    private(set) var isSubmitting = false
    private(set) var submitError: String?

    var handle: String {
        name.filter { !$0.isWhitespace }
    }

    var isRenamed: Bool {
        handle != name && !handle.isEmpty
    }

    private var trimmedDescription: String {
        description.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nameError: String? {
        if handle.isEmpty { return "Name is required" }
        if handle.count < 3 { return "Name must be at least 3 characters" }
        if handle.count > Self.nameLimit { return "Name must be under \(Self.nameLimit) characters" }
        return nil
    }

    var descriptionError: String? {
        if trimmedDescription.isEmpty { return "Description is required" }
        if trimmedDescription.count < 10 { return "Description must be at least 10 characters" }
        if description.count > Self.descriptionLimit {
            return "Description must be under \(Self.descriptionLimit) characters"
        }
        return nil
    }

    var canSubmit: Bool {
        nameError == nil && descriptionError == nil && !isSubmitting
    }

    var hasContent: Bool {
        !handle.isEmpty || !trimmedDescription.isEmpty
    }

    var nameRemaining: Int {
        Self.nameLimit - handle.count
    }

    func visibleError(_ error: String?) -> String? {
        hasAttemptedSubmit ? error : nil
    }

    func submit(using viewModel: CommunityViewModel) async -> Community? {
        hasAttemptedSubmit = true
        submitError = nil
        guard canSubmit else { return nil }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            return try await viewModel.createCommunity(name: handle, description: trimmedDescription)
        } catch APIError.serverError {
            submitError = "Couldn't create the community. That name may already be taken."
            return nil
        } catch {
            submitError = error.userMessage(fallback: "Couldn't create the community.")
            return nil
        }
    }
}

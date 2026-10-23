import Foundation

@MainActor
@Observable
final class CreateCommunityViewModel {
    static let nameMin = 3
    static let nameLimit = 255
    static let descriptionMin = 10
    static let descriptionLimit = 2000

    private static let nameTakenMessage = "Couldn't create the community. That name may already be taken."

    private(set) var name = ""
    private(set) var description = ""
    private(set) var isSubmitted = false
    private(set) var isSubmitting = false
    private(set) var createdCommunity: Community?
    var toastMessage: String?

    private let repository: CommunityRepository

    init(repository: CommunityRepository) {
        self.repository = repository
    }

    var handle: String {
        name.filter { !$0.isWhitespace }
    }

    var trimmedDescription: String {
        description.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isRenamed: Bool {
        handle != name && !handle.isEmpty
    }

    var hasContent: Bool {
        !handle.isEmpty || !trimmedDescription.isEmpty
    }

    var nameRemaining: Int {
        Self.nameLimit - handle.count
    }

    var nameError: String? {
        isSubmitted ? Self.nameError(for: handle) : nil
    }

    var descriptionError: String? {
        isSubmitted ? Self.descriptionError(for: trimmedDescription) : nil
    }

    var canSubmit: Bool {
        Self.nameError(for: handle) == nil && Self.descriptionError(for: trimmedDescription) == nil
    }

    func onNameChange(_ value: String) {
        name = value
    }

    func onDescriptionChange(_ value: String) {
        description = value
    }

    func submit() async -> Community? {
        guard !isSubmitting, createdCommunity == nil else { return nil }
        isSubmitted = true
        guard canSubmit else { return nil }

        isSubmitting = true
        toastMessage = nil
        defer { isSubmitting = false }

        do {
            let created = try await repository.createCommunity(title: handle, description: trimmedDescription)
            createdCommunity = created
            return created
        } catch APIError.serverError {
            toastMessage = Self.nameTakenMessage
        } catch {
            toastMessage = error.userMessage()
        }
        return nil
    }

    private static func nameError(for handle: String) -> String? {
        if handle.isEmpty { return "Name is required" }
        if handle.count < nameMin { return "At least \(nameMin) characters" }
        if handle.count > nameLimit { return "Name must be at most \(nameLimit) characters" }
        return nil
    }

    private static func descriptionError(for description: String) -> String? {
        if description.isEmpty { return "Description is required" }
        if description.count < descriptionMin { return "At least \(descriptionMin) characters" }
        if description.count > descriptionLimit {
            return "Description must be at most \(descriptionLimit) characters"
        }
        return nil
    }
}

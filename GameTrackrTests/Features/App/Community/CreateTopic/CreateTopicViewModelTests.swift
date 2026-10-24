import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct CreateTopicViewModelTests {
    private static let community = CommunityMockData.all.first { $0.isJoined }!
    private static let title = "Best co-op games of the year?"
    private static let body = "Looking for something to play with friends this weekend."

    private let repository = FakeCommunityRepository(latency: .zero)
    private let postUpdates = PostUpdates()

    private func viewModel(
        locked: Community? = Self.community,
        title: String = Self.title,
        body: String = Self.body
    ) -> CreateTopicViewModel {
        let viewModel = CreateTopicViewModel(community: locked, repository: repository, postUpdates: postUpdates)
        viewModel.onTitleChange(title)
        viewModel.onBodyChange(body)
        return viewModel
    }

    @Test func errorsShowOnlyAfterTheFirstSubmit() async {
        let viewModel = viewModel(locked: nil, title: "", body: "")
        #expect(viewModel.titleError == nil)

        let created = await viewModel.submit()

        #expect(created == nil)
        #expect(viewModel.communityError == "Pick a community")
        #expect(viewModel.titleError == "Title is required")
        #expect(viewModel.bodyError == "Body is required")
        #expect(await repository.createPostCount == 0)
    }

    @Test func submitSendsTheTrimmedPostAndPublishesIt() async {
        var published: [CommunityPost] = []
        let observer = NSObject()
        postUpdates.observeCreated(observer) { published.append($0) }
        let viewModel = viewModel(title: "  \(Self.title)  ", body: "  \(Self.body)  ")

        let created = await viewModel.submit()

        #expect(created?.title == Self.title)
        #expect(created?.preview == Self.body)
        #expect(created?.communityId == Self.community.id)
        #expect(viewModel.createdPost == created)
        #expect(published == [created].compactMap(\.self))
        #expect(!viewModel.isSubmitting)
    }

    @Test func aCreateFailureShowsAToastAndKeepsTheForm() async {
        var published: [CommunityPost] = []
        let observer = NSObject()
        postUpdates.observeCreated(observer) { published.append($0) }
        await repository.setFailure(APIError.networkFailure)
        let viewModel = viewModel()

        let created = await viewModel.submit()

        #expect(created == nil)
        #expect(viewModel.toastMessage == APIError.networkFailure.userMessage())
        #expect(viewModel.title == Self.title)
        #expect(viewModel.createdPost == nil)
        #expect(published.isEmpty)
    }

    @Test func submitAfterASuccessfulCreateSendsNoRequest() async {
        let viewModel = viewModel()
        _ = await viewModel.submit()

        let second = await viewModel.submit()

        #expect(second == nil)
        #expect(await repository.createPostCount == 1)
    }

    @Test func aSecondTapWhilePostingSendsNoRequest() async {
        let slowRepository = FakeCommunityRepository(latency: .milliseconds(50))
        let viewModel = CreateTopicViewModel(
            community: Self.community,
            repository: slowRepository,
            postUpdates: postUpdates
        )
        viewModel.onTitleChange(Self.title)
        viewModel.onBodyChange(Self.body)

        async let first = viewModel.submit()
        async let second = viewModel.submit()
        _ = await (first, second)

        #expect(await slowRepository.createPostCount == 1)
    }

    @Test func aLockedCommunityIsSelectedRightAwayWithoutLoadingTheJoinedList() async {
        let viewModel = viewModel()

        await viewModel.loadIfNeeded()

        #expect(viewModel.community == Self.community)
        #expect(viewModel.isCommunityLocked)
        #expect(viewModel.communities.isEmpty)
        viewModel.onCommunityChange(CommunityMockData.all[CommunityMockData.all.count - 1])
        #expect(viewModel.community == Self.community)
    }

    @Test func aJoinedCommunitiesFailureShowsAnErrorAndRetryLoadsThem() async {
        await repository.setFailure(APIError.networkFailure)
        let viewModel = viewModel(locked: nil)

        await viewModel.loadIfNeeded()
        #expect(viewModel.communitiesFailed)

        await repository.setFailure(nil)
        await viewModel.retryCommunities()

        #expect(!viewModel.communitiesFailed)
        #expect(!viewModel.communities.isEmpty)
        #expect(!viewModel.communities.contains { !$0.isJoined })
    }

    @Test func titleLimitIgnoresSurroundingWhitespaceAndSaysAtMost() async {
        let longest = String(repeating: "a", count: CreateTopicViewModel.titleLimit)
        #expect(viewModel(title: "  \(longest)  ").canSubmit)

        let viewModel = viewModel(title: longest + "a")
        _ = await viewModel.submit()

        #expect(viewModel.titleError == "Title must be at most \(CreateTopicViewModel.titleLimit) characters")
        #expect(await repository.createPostCount == 0)
    }
}

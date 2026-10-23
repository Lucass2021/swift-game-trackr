import SwiftUI

struct AddToLibraryForm: View {
    let viewModel: AddToLibraryViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                AddToLibraryField(label: "Playing status") {
                    StatusSelectGrid(selection: binding(viewModel.status, viewModel.onStatusChange))
                }

                AddToLibraryField(label: "Rating") {
                    InteractiveStarRating(rating: binding(viewModel.rating, viewModel.onRatingChange))
                }

                HStack(alignment: .top, spacing: Spacing.sm) {
                    AddToLibraryField(label: "Hours played") {
                        NumberField(value: binding(viewModel.hours, viewModel.onHoursChange), placeholder: "42")
                    }
                    if let platform = viewModel.platform {
                        AddToLibraryField(label: "Platform") {
                            PlatformPicker(
                                selection: binding(platform, viewModel.onPlatformChange),
                                options: viewModel.platforms
                            )
                        }
                    }
                }
                .zIndex(1)

                HStack(alignment: .top, spacing: Spacing.sm) {
                    AddToLibraryField(label: "Started") {
                        DateField(date: binding(viewModel.startedAt, viewModel.onStartedChange))
                    }
                    AddToLibraryField(label: "Finished", error: viewModel.dateError) {
                        DateField(
                            date: binding(viewModel.finishedAt, viewModel.onFinishedChange),
                            isError: viewModel.dateError != nil
                        )
                    }
                }

                AddToLibraryField(label: "Review") {
                    ReviewField(
                        value: binding(viewModel.review, viewModel.onReviewChange),
                        placeholder: "Write a short review..."
                    )
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.lg)
        }
    }

    private func binding<Value>(_ value: Value, _ onChange: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(get: { value }, set: onChange)
    }
}

#Preview {
    AddToLibraryForm(viewModel: AddToLibraryViewModel(
        slug: "neon-ascent-revival",
        game: FakeGameRepository.gameDetail,
        repository: FakeLibraryRepository(),
        libraryUpdates: LibraryUpdates()
    ))
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

import SwiftUI

struct AddToLibrarySheet: View {
    let gameTitle: String
    var coverStart: Color = .coverVioletStart
    var coverEnd: Color = .coverVioletEnd

    @Environment(\.dismiss) private var dismiss

    @State private var status: LibraryStatus = .playing
    @State private var rating = 0
    @State private var hours = ""
    @State private var platform = "PS5"
    @State private var started: Date?
    @State private var finished: Date?
    @State private var review = ""

    private let platforms = ["PS5", "PS4", "Xbox Series X|S", "PC", "Nintendo Switch"]

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    field("Playing status") {
                        StatusSelectGrid(selection: $status)
                    }

                    field("Rating") {
                        InteractiveStarRating(rating: $rating)
                    }

                    HStack(alignment: .top, spacing: 14) {
                        field("Hours played") {
                            SheetNumberField(value: $hours, placeholder: "42")
                        }
                        field("Platform") {
                            PlatformPicker(selection: $platform, options: platforms)
                        }
                    }
                    .zIndex(1)

                    HStack(alignment: .top, spacing: 14) {
                        field("Started") {
                            DateField(date: $started)
                        }
                        field("Finished") {
                            DateField(date: $finished)
                        }
                    }

                    field("Review") {
                        reviewEditor
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            PrimaryButton(title: "Save to library", icon: .addToLibrary) {
                dismiss()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(Color.appBackground)
        }
        .background(Color.appBackground)
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 14) {
            GameCoverArt(start: coverStart, end: coverEnd, width: 56, height: 56)

            VStack(alignment: .leading, spacing: 3) {
                Text("Add to Library")
                    .font(.appHeadline(22))
                    .foregroundStyle(Color.appTextPrimary)
                Text(gameTitle)
                    .font(.appBody(14))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }

            Spacer()
        }
    }

    private var reviewEditor: some View {
        TextField(
            "",
            text: $review,
            prompt: Text("Write a short review...").foregroundStyle(Color.appTextSecondary),
            axis: .vertical
        )
        .font(.appBody(16))
        .foregroundStyle(Color.appTextPrimary)
        .tint(Color.appPrimary)
        .lineLimit(4 ... 6)
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
    }

    private func field(_ label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel(text: label)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    Color.appBackground
        .sheet(isPresented: .constant(true)) {
            AddToLibrarySheet(gameTitle: "Neon Ascent: Revival")
        }
        .preferredColorScheme(.dark)
}

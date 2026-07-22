import SwiftUI

struct DiscoverCommunitiesView: View {
    @Binding var category: String
    @Binding var communities: [Community]
    var onSelect: (Community) -> Void = { _ in }

    @State private var query = ""

    private var filtered: [Community] {
        communities.filter { community in
            let matchesCategory = category == "All" || community.category == category
            let matchesQuery = query.trimmingCharacters(in: .whitespaces).isEmpty
                || community.name.localizedCaseInsensitiveContains(query)
            return matchesCategory && matchesQuery
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                CommunitySearchField(query: $query)
                    .padding(.horizontal, 20)

                CommunityChipRow(titles: CommunityMockData.categories, selection: $category)

                featured

                if filtered.isEmpty {
                    CommunityEmptyState(
                        icon: .search,
                        title: "No communities found",
                        message: "Try a different name or clear the filters to see everything.",
                        actionTitle: "Clear filters",
                        action: {
                            query = ""
                            category = "All"
                        }
                    )
                } else {
                    allCommunities
                }
            }
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var featured: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: "Featured", onViewAll: {})

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(CommunityMockData.featured) { community in
                        FeaturedCommunityCard(
                            community: community,
                            onSelect: { onSelect(community) },
                            onJoin: { toggleJoin(community) }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var allCommunities: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("All communities")
                .font(.appHeadline(22))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            ForEach(filtered) { community in
                CommunityRow(
                    community: community,
                    onSelect: { onSelect(community) },
                    onJoin: { toggleJoin(community) }
                )

                if community.id != filtered.last?.id {
                    Rectangle()
                        .fill(Color.appOutline)
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                }
            }
        }
    }

    private func toggleJoin(_ community: Community) {
        guard let index = communities.firstIndex(where: { $0.id == community.id }) else { return }
        communities[index].isJoined.toggle()
    }
}

#Preview {
    @Previewable @State var category = "All"
    @Previewable @State var communities = CommunityMockData.all
    DiscoverCommunitiesView(category: $category, communities: $communities)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

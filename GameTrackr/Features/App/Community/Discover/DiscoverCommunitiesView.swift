import SwiftUI

struct DiscoverCommunitiesView: View {
    @Binding var category: String
    let communities: [Community]
    var isLoadingMore = false
    var canLoadMore = false
    var onSelect: (Community) -> Void = { _ in }
    var onJoin: (Community) -> Void = { _ in }
    var onLoadMore: () -> Void = {}

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
                        message: "Try a different search or category."
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
                    ForEach(communities.prefix(3)) { community in
                        FeaturedCommunityCard(
                            community: community,
                            onSelect: { onSelect(community) },
                            onJoin: { onJoin(community) }
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

            ForEach(Array(filtered.enumerated()), id: \.element.id) { index, community in
                CommunityRow(
                    community: community,
                    onSelect: { onSelect(community) },
                    onJoin: { onJoin(community) }
                )
                .onAppear {
                    if index >= filtered.count - 3 {
                        onLoadMore()
                    }
                }

                if community.id != filtered.last?.id {
                    Rectangle()
                        .fill(Color.appOutline)
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                }
            }

            if isLoadingMore {
                LoadingMoreIndicator()
            }
        }
    }
}

#Preview {
    @Previewable @State var category = "All"
    DiscoverCommunitiesView(category: $category, communities: CommunityMockData.all)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

nonisolated func fakePage<Item>(items: [Item], page: Int, perPage: Int) -> Page<Item> {
    let lastPage = max(1, (items.count + perPage - 1) / perPage)
    let start = min((page - 1) * perPage, items.count)
    let end = min(start + perPage, items.count)
    return Page(
        items: Array(items[start ..< end]),
        currentPage: page,
        lastPage: lastPage,
        total: items.count
    )
}

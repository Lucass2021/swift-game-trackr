struct AboutUiState: Equatable {
    let versionName: String

    var versionText: String {
        "Version \(versionName)"
    }
}

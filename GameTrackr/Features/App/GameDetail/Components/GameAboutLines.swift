enum GameAboutLines {
    static let collapsed = 3
    static let fullyShownMax = 5

    static func maxLines(expanded: Bool, collapsible: Bool?) -> Int? {
        guard let collapsible else { return fullyShownMax }
        return expanded || !collapsible ? nil : collapsed
    }

    static func showsToggle(collapsible: Bool?) -> Bool {
        collapsible == true
    }
}

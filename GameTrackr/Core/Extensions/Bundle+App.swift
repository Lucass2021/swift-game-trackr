import Foundation

extension Bundle {
    var versionName: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}

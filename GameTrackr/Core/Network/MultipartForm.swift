import Foundation

nonisolated struct MultipartForm {
    private let boundary = "Boundary-\(UUID().uuidString)"
    private var body = Data()

    var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    var encoded: Data {
        body + Data("--\(boundary)--\r\n".utf8)
    }

    mutating func addField(_ name: String, value: String) {
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        append("\(value)\r\n")
    }

    mutating func addFile(_ name: String, fileName: String, mimeType: String, data: Data) {
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
        append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        append("\r\n")
    }

    private mutating func append(_ text: String) {
        body.append(Data(text.utf8))
    }
}

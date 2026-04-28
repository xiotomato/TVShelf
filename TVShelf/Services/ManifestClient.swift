import Foundation

protocol ManifestProviding {
    func fetchManifest(for date: Date) async throws -> ContentManifest
}

enum ManifestClientError: LocalizedError {
    case invalidResponse
    case missingSampleManifest

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The manifest server returned invalid data."
        case .missingSampleManifest:
            return "No remote manifest URL is configured yet."
        }
    }
}

struct ManifestClient: ManifestProviding {
    private let decoder: JSONDecoder
    private let session: URLSession
    private let calendar: Calendar

    init(
        session: URLSession = .shared,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) {
        self.session = session
        self.calendar = calendar
        self.decoder = JSONDecoder()
    }

    func fetchManifest(for date: Date) async throws -> ContentManifest {
        if let remoteURL = AppConfiguration.manifestURL {
            var request = URLRequest(url: remoteURL)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.timeoutInterval = 20

            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200 ..< 300).contains(httpResponse.statusCode) else {
                throw ManifestClientError.invalidResponse
            }

            return try decoder.decode(ContentManifest.self, from: data)
        }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.dateFormat = "yyyy-MM-dd"

        let datedPreview = ContentManifest(
            effectiveDate: formatter.string(from: date),
            heading: ContentManifest.preview.heading,
            subheading: ContentManifest.preview.subheading,
            videos: ContentManifest.preview.videos
        )

        return datedPreview
    }
}

enum AppConfiguration {
    private static let manifestURLKey = "TVSHELF_MANIFEST_URL"

    static var manifestURL: URL? {
        guard let rawValue = ProcessInfo.processInfo.environment[manifestURLKey], !rawValue.isEmpty else {
            return nil
        }

        return URL(string: rawValue)
    }
}

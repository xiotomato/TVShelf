import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var manifest: ContentManifest?
    @Published private(set) var watchedIDs: Set<String> = []
    @Published private(set) var loadState: LoadState = .idle
    @Published private(set) var lastRefreshDescription: String = "Waiting for first sync"

    private let manifestClient: ManifestProviding
    private let watchHistoryStore: WatchHistoryStoring
    private let timezone: TimeZone

    private let activeDayKeyStoreKey = "tvshelf.active-day-key"
    private let lastRefreshTimestampKey = "tvshelf.last-refresh"

    init(
        manifestClient: ManifestProviding,
        watchHistoryStore: WatchHistoryStoring,
        timezone: TimeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
    ) {
        self.manifestClient = manifestClient
        self.watchHistoryStore = watchHistoryStore
        self.timezone = timezone
    }

    var availableVideos: [VideoItem] {
        guard let manifest else { return [] }
        return manifest.videos
    }

    var hasFinishedToday: Bool {
        guard let manifest else { return false }
        return !manifest.videos.isEmpty && watchedIDs.count >= manifest.videos.count
    }

    var currentDayKey: String {
        Self.dayFormatter(timezone: timezone).string(from: Date())
    }

    func handleAppActivation(forceRefresh: Bool) async {
        let isNewDay = UserDefaults.standard.string(forKey: activeDayKeyStoreKey) != currentDayKey
        let shouldReload = forceRefresh || manifest == nil || isNewDay
        guard shouldReload else { return }

        await refreshForCurrentDay()
    }

    func refreshForCurrentDay() async {
        loadState = .loading

        do {
            let newManifest = try await manifestClient.fetchManifest(for: Date())
            let previousDayKey = UserDefaults.standard.string(forKey: activeDayKeyStoreKey)

            if previousDayKey != newManifest.dayKey {
                watchHistoryStore.clearAll()
                watchHistoryStore.reset(for: newManifest.dayKey)
            }

            manifest = newManifest
            watchedIDs = watchHistoryStore.watchedIDs(for: newManifest.dayKey)
            loadState = .loaded
            UserDefaults.standard.set(newManifest.dayKey, forKey: activeDayKeyStoreKey)
            UserDefaults.standard.set(Date(), forKey: lastRefreshTimestampKey)
            lastRefreshDescription = Self.relativeRefreshDescription(from: Date())
        } catch {
            loadState = .failed(error.localizedDescription)
            if let timestamp = UserDefaults.standard.object(forKey: lastRefreshTimestampKey) as? Date {
                lastRefreshDescription = Self.relativeRefreshDescription(from: timestamp)
            }
        }
    }

    func markWatched(_ video: VideoItem) {
        guard let manifest else { return }
        watchHistoryStore.markWatched(video.id, for: manifest.dayKey)
        watchedIDs = watchHistoryStore.watchedIDs(for: manifest.dayKey)
    }

    static func relativeRefreshDescription(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        if abs(seconds) < 60 {
            return "Updated just now"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let relative = formatter.localizedString(for: date, relativeTo: Date())
        if relative.hasPrefix("in ") {
            return "Updated just now"
        }
        return "Updated " + relative
    }

    private static func dayFormatter(timezone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timezone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

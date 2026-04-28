import Foundation

protocol WatchHistoryStoring {
    func watchedIDs(for dayKey: String) -> Set<String>
    func markWatched(_ id: String, for dayKey: String)
    func reset(for dayKey: String)
    func clearAll()
}

final class WatchHistoryStore: WatchHistoryStoring {
    private let defaults: UserDefaults
    private let watchedPrefix = "tvshelf.watched."

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func watchedIDs(for dayKey: String) -> Set<String> {
        let values = defaults.array(forKey: watchedPrefix + dayKey) as? [String] ?? []
        return Set(values)
    }

    func markWatched(_ id: String, for dayKey: String) {
        var values = watchedIDs(for: dayKey)
        values.insert(id)
        defaults.set(Array(values), forKey: watchedPrefix + dayKey)
    }

    func reset(for dayKey: String) {
        defaults.removeObject(forKey: watchedPrefix + dayKey)
    }

    func clearAll() {
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(watchedPrefix) {
            defaults.removeObject(forKey: key)
        }
    }
}

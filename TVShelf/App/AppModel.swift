import Combine
import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published var state: HomeViewModel

    init() {
        self.state = HomeViewModel(
            manifestClient: ManifestClient(),
            watchHistoryStore: WatchHistoryStore()
        )
    }
}

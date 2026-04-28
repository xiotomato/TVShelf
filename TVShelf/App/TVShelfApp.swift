import SwiftUI

@main
struct TVShelfApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: appModel.state)
                .task {
                    await appModel.state.handleAppActivation(forceRefresh: false)
                }
        }
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }

            Task {
                await appModel.state.handleAppActivation(forceRefresh: false)
            }
        }
    }
}

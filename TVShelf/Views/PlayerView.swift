import AVKit
import SwiftUI

struct PlayerView: View {
    let video: VideoItem
    let onPlaybackFinished: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var player = AVPlayer()
    @State private var finished = false
    @State private var observedItem: AVPlayerItem?

    var body: some View {
        VideoPlayer(player: player)
            .ignoresSafeArea()
            .background(Color.black)
            .onAppear {
                let item = AVPlayerItem(url: video.streamURL)
                observedItem = item
                player.replaceCurrentItem(with: item)
                player.play()
            }
            .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { notification in
                guard let observedItem, let completedItem = notification.object as? AVPlayerItem, completedItem === observedItem, !finished else { return }
                finished = true
                onPlaybackFinished()
                dismiss()
            }
            .onDisappear {
                player.pause()
                observedItem = nil
            }
    }
}

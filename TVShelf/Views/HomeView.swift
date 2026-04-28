import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedVideo: VideoItem?
    @FocusState private var focusedVideoID: VideoItem.ID?

    var body: some View {
        ZStack {
            AppTheme.gradient
                .ignoresSafeArea()

            ambientBackground

            content
                .padding(.horizontal, 86)
                .padding(.vertical, 64)
        }
        .fullScreenCover(item: $selectedVideo) { video in
            PlayerView(video: video) {
                viewModel.markWatched(video)
            }
        }
        .onPlayPauseCommand {
            playFocusedVideo()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.manifest == nil {
            switch viewModel.loadState {
            case .idle, .loading, .loaded:
                ProgressView("Loading today's lineup...")
                    .tint(.white)
                    .foregroundStyle(.white)

            case .failed(let message):
                PlaybackGateView(
                    title: "Unable to load today's videos",
                    message: message,
                    actionTitle: "Try again"
                ) {
                    Task { await viewModel.refreshForCurrentDay() }
                }
            }
        } else if viewModel.hasFinishedToday {
            PlaybackGateView(
                title: "Today's set is complete",
                message: "The three videos for today have been watched. New picks will appear after the next refresh day.",
                actionTitle: "Refresh now"
            ) {
                Task { await viewModel.refreshForCurrentDay() }
            }
        } else {
            loadedView
        }
    }

    private var loadedView: some View {
        VStack(alignment: .leading, spacing: 28) {
            header

            if let manifest = viewModel.manifest {
                bentoGrid(videos: manifest.videos)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task {
            focusedVideoID = viewModel.availableVideos.first(where: { !viewModel.watchedIDs.contains($0.id) })?.id
        }
    }

    private func bentoGrid(videos: [VideoItem]) -> some View {
        HStack(alignment: .top, spacing: 24) {
            if let firstVideo = videos.first {
                VideoCardView(
                    video: firstVideo,
                    isWatched: viewModel.watchedIDs.contains(firstVideo.id),
                    isFocused: focusedVideoID == firstVideo.id,
                    style: .featured
                )
                .focusable(!viewModel.watchedIDs.contains(firstVideo.id))
                .focused($focusedVideoID, equals: firstVideo.id)
                .onTapGesture { play(firstVideo) }
                .opacity(viewModel.watchedIDs.contains(firstVideo.id) ? 0.42 : 1.0)
                .accessibilityLabel(firstVideo.title)
            }

            VStack(spacing: 24) {
                ForEach(videos.dropFirst()) { video in
                    VideoCardView(
                        video: video,
                        isWatched: viewModel.watchedIDs.contains(video.id),
                        isFocused: focusedVideoID == video.id,
                        style: .compact
                    )
                    .focusable(!viewModel.watchedIDs.contains(video.id))
                    .focused($focusedVideoID, equals: video.id)
                    .onTapGesture { play(video) }
                    .opacity(viewModel.watchedIDs.contains(video.id) ? 0.42 : 1.0)
                    .accessibilityLabel(video.title)
                }
            }

            dailyStatusPanel
        }
        .padding(.top, 8)
    }

    private var dailyStatusPanel: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Shelf")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.muted)

                Text("\(viewModel.availableVideos.count - viewModel.watchedIDs.count) left")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }

            HStack(spacing: 10) {
                ForEach(viewModel.availableVideos) { video in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(viewModel.watchedIDs.contains(video.id) ? AppTheme.accent : Color.white.opacity(0.20))
                        .frame(width: 42, height: 8)
                }
            }

            Divider()
                .overlay(Color.white.opacity(0.16))

            VStack(alignment: .leading, spacing: 14) {
                Label("Refreshes after midnight", systemImage: "calendar")
                Label("Only today's videos are shown", systemImage: "lock")
                Label("Direct streams only", systemImage: "play.rectangle")
            }
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(AppTheme.muted)

            Spacer(minLength: 0)

            Label(viewModel.lastRefreshDescription, systemImage: "arrow.triangle.2.circlepath")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.accentWarm)
        }
        .frame(width: 300, height: 548, alignment: .topLeading)
        .padding(24)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(AppTheme.materialStroke, lineWidth: 1)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TVShelf")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.muted)

            Text(viewModel.manifest?.heading ?? "Today's lineup")
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(.white)

            Text(viewModel.manifest?.subheading ?? "Fresh videos will appear when the next day starts.")
                .font(.system(size: 23, weight: .regular))
                .foregroundStyle(AppTheme.muted)
                .lineLimit(2)
        }
    }

    private var footer: some View {
        EmptyView()
    }

    private var progressBadge: some View {
        EmptyView()
    }

    private var ambientBackground: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.gradient)

            VStack {
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 1)
                Spacer()
            }

            LinearGradient(
                colors: [
                    Color.white.opacity(0.05),
                    Color.clear,
                    Color.black.opacity(0.24)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    private func play(_ video: VideoItem) {
        guard !viewModel.watchedIDs.contains(video.id) else { return }
        selectedVideo = video
    }

    private func playFocusedVideo() {
        guard let focusedVideoID, let video = viewModel.availableVideos.first(where: { $0.id == focusedVideoID }) else {
            return
        }

        play(video)
    }
}

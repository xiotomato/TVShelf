import SwiftUI

struct VideoCardView: View {
    enum Style {
        case featured
        case compact

        var size: CGSize {
            switch self {
            case .featured:
                CGSize(width: 560, height: 548)
            case .compact:
                CGSize(width: 390, height: 262)
            }
        }

        var artworkHeight: CGFloat {
            switch self {
            case .featured:
                354
            case .compact:
                146
            }
        }
    }

    let video: VideoItem
    let isWatched: Bool
    let isFocused: Bool
    let style: Style

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.regularMaterial)

            VStack(alignment: .leading, spacing: 0) {
                artwork

                VStack(alignment: .leading, spacing: style == .featured ? 12 : 8) {
                    Text(video.title)
                        .font(.system(size: style == .featured ? 34 : 23, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(video.subtitle)
                        .font(.system(size: style == .featured ? 20 : 16, weight: .regular))
                        .foregroundStyle(AppTheme.muted)
                        .lineLimit(style == .featured ? 2 : 1)

                    HStack(spacing: 12) {
                        Label(video.durationText, systemImage: "clock")
                        if isWatched {
                            Label("Watched", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(AppTheme.accent)
                        } else {
                            Label(isFocused ? "Play" : "Ready", systemImage: "play.fill")
                                .foregroundStyle(AppTheme.accentWarm)
                        }
                    }
                    .font(.system(size: 15, weight: .semibold))
                }
                .padding(style == .featured ? 24 : 18)
            }
            .padding(8)

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(isFocused ? AppTheme.accent : Color.white.opacity(0.08), lineWidth: isFocused ? 4 : 1)

            if isFocused && !isWatched {
                Image(systemName: "play.fill")
                    .font(.system(size: style == .featured ? 24 : 18, weight: .black))
                    .foregroundStyle(.black.opacity(0.82))
                    .frame(width: style == .featured ? 58 : 44, height: style == .featured ? 58 : 44)
                    .background(AppTheme.accentWarm)
                    .clipShape(Circle())
                    .shadow(color: AppTheme.accentWarm.opacity(0.28), radius: 14, y: 7)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(style == .featured ? 24 : 18)
            }
        }
        .frame(width: style.size.width, height: style.size.height)
        .shadow(color: isFocused ? Color.black.opacity(0.38) : Color.black.opacity(0.22), radius: isFocused ? 28 : 18, y: isFocused ? 18 : 10)
        .scaleEffect(isFocused ? 1.025 : 1.0)
        .animation(.easeOut(duration: 0.18), value: isFocused)
        .zIndex(isFocused ? 1 : 0)
    }

    private var artwork: some View {
        AsyncImage(url: video.posterURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Rectangle()
                    .fill(AppTheme.panelSecondary)
            case .empty:
                Rectangle()
                    .fill(AppTheme.panel)
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            @unknown default:
                Rectangle()
                    .fill(AppTheme.panelSecondary)
            }
        }
        .frame(width: style.size.width - 16, height: style.artworkHeight)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(alignment: .topLeading) {
            Text(video.category.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.92))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .padding(14)
        }
    }
}

import Foundation

struct ContentManifest: Decodable, Equatable {
    let effectiveDate: String
    let heading: String
    let subheading: String
    let videos: [VideoItem]

    var dayKey: String {
        effectiveDate
    }

    static let preview = ContentManifest(
        effectiveDate: "2026-04-26",
        heading: "Today on the big screen",
        subheading: "Three calm, high-quality picks prepared for one focused session.",
        videos: [
            VideoItem(
                id: "ocean-engineering",
                title: "How a giant ship stays balanced at sea",
                subtitle: "Engineering and everyday physics",
                posterURL: URL(string: "https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=1200&q=80")!,
                streamURL: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/adv_dv_atmos/main.m3u8")!,
                durationText: "11 min",
                category: "Engineering"
            ),
            VideoItem(
                id: "bird-migration",
                title: "Why birds know exactly when to fly south",
                subtitle: "Nature, seasons, and navigation",
                posterURL: URL(string: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80")!,
                streamURL: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!,
                durationText: "10 min",
                category: "Nature"
            ),
            VideoItem(
                id: "night-train",
                title: "A quiet look inside a long-distance night train",
                subtitle: "Travel, routine, and real-world systems",
                posterURL: URL(string: "https://images.unsplash.com/photo-1474487548417-781cb71495f3?auto=format&fit=crop&w=1200&q=80")!,
                streamURL: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9_variant.m3u8")!,
                durationText: "13 min",
                category: "Transport"
            )
        ]
    )
}

struct VideoItem: Decodable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let posterURL: URL
    let streamURL: URL
    let durationText: String
    let category: String
}

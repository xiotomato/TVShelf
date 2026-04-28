# TVShelf

Minimal tvOS daily video shelf built for a closed, child-friendly viewing flow.

## What it does

- Fetches a remote JSON manifest when the app becomes active
- Detects day rollover and swaps in a fresh daily lineup
- Clears the previous day's watch history automatically
- Plays only the videos listed in the manifest
- Locks the shelf after all daily videos are watched

## Intake interface

The app is intentionally simple: the transfer interface is a remote JSON manifest plus direct stream URLs.

Set the manifest endpoint with an environment variable when you run the app in Xcode:

```bash
TVSHELF_MANIFEST_URL=https://example.com/today.json
```

Expected payload:

```json
{
  "effectiveDate": "2026-04-26",
  "heading": "Today on the big screen",
  "subheading": "Three calm, high-quality picks prepared for one focused session.",
  "videos": [
    {
      "id": "train-cabin-tour",
      "title": "A quiet look inside a long-distance night train",
      "subtitle": "Travel, routine, and real-world systems",
      "posterURL": "https://cdn.example.com/posters/train.jpg",
      "streamURL": "https://cdn.example.com/streams/train.m3u8",
      "durationText": "13 min",
      "category": "Transport"
    }
  ]
}
```

## Notes

- `streamURL` should be a direct playable URL such as `m3u8` or `mp4`.
- A normal Bilibili page URL is not suitable for `AVPlayer`.
- tvOS uses `SwiftUI`, `UIKit`, and `AVKit`, not `AppKit`.
- The current project avoids extra settings, search, history, and recommendation surfaces on purpose.

import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.045, green: 0.047, blue: 0.052)
    static let panel = Color.white.opacity(0.105)
    static let panelSecondary = Color.white.opacity(0.075)
    static let materialStroke = Color.white.opacity(0.14)
    static let accent = Color(red: 0.42, green: 0.76, blue: 1.0)
    static let accentWarm = Color(red: 1.0, green: 0.84, blue: 0.45)
    static let muted = Color.white.opacity(0.66)
    static let gradient = LinearGradient(
        colors: [
            Color(red: 0.10, green: 0.105, blue: 0.115),
            Color(red: 0.045, green: 0.047, blue: 0.052),
            Color.black
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

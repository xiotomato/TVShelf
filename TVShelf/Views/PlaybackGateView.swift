import SwiftUI

struct PlaybackGateView: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(AppTheme.accent)

            Text(title)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.white)

            Text(message)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 720)

            Button(actionTitle, action: action)
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .font(.system(size: 21, weight: .semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(AppTheme.materialStroke, lineWidth: 1)
                }
                .padding(.horizontal, 180)
                .padding(.vertical, 120)
        )
    }
}

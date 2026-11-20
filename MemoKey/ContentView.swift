import SwiftUI

struct ContentView: View {
    @ObservedObject var model: OverlayModel

    var body: some View {
        ZStack {
            if let item = model.item {
                card(for: item)
                    .id(item.id)
                    .scaleEffect(model.faded ? 1.18 : 1.0)
                    .opacity(model.faded ? 0 : 1)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .identity
                    ))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private func card(for item: DisplayItem) -> some View {
        HStack(spacing: 10) {
            ForEach(Array(item.keys.enumerated()), id: \.offset) { index, key in
                if index > 0 {
                    Text("+")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
                KeyCapView(label: key)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.black.opacity(0.66))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 16, y: 6)
    }
}

private struct KeyCapView: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.system(size: 26, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(minWidth: 42, minHeight: 44)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.16))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
            )
    }
}

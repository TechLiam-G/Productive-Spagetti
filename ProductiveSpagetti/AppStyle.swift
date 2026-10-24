import SwiftUI

struct AppBackdrop: View {
    var body: some View {
        LinearGradient(
            colors: [Color(red: 0.92, green: 0.95, blue: 1), Color(red: 0.94, green: 0.90, blue: 1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

extension View {
    func appCard(cornerRadius: CGFloat = 24) -> some View {
        padding()
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.8), lineWidth: 1)
                    .allowsHitTesting(false)
            }
    }
}

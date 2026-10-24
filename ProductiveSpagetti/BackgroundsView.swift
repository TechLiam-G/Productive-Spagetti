
import SwiftUI

extension Notification.Name {
    static let productiveSpagettiThemeDidChange = Notification.Name("productiveSpagettiThemeDidChange")
}

struct BackgroundsView: View {

    @AppStorage("backgrounds") private var backgrounds = ""
    @AppStorage("equippedBackground") private var equippedBackground = "default"
    @State private var selectedTheme = "default"

    private let themes = [
        "default",
        "outerspace",
        "sunset",
        "aurora",
        "rain_code"
    ]

    var body: some View {
        ZStack {
            AppBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text("My focus themes")
                        .font(.largeTitle.bold())

                    Text("Equip a theme to make each productive run feel like your own.")
                        .foregroundStyle(.secondary)

                    Label(
                        "Equipped: \(themeName(selectedTheme))",
                        systemImage: "checkmark.seal.fill"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)

                    ForEach(themes, id: \.self) { theme in

                        if theme == "default" || ownedThemes.contains(theme) {
                            themeCard(theme)
                        }

                    }
                    .id(selectedTheme)
                }
                .padding(28)
            }
        }
        .onAppear {
            selectedTheme = savedEquippedTheme
        }
        .onChange(of: equippedBackground) { _, newTheme in
            selectedTheme = newTheme
        }
    }

    // MARK: - Theme Card

    private func themeCard(_ theme: String) -> some View {

        return VStack(alignment: .leading, spacing: 12) {

            themePreview(theme)
                .frame(maxWidth: .infinity)
                .frame(height: 145)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 18,
                        style: .continuous
                    )
                )

            HStack {

                VStack(alignment: .leading, spacing: 3) {

                    Text(themeName(theme))
                        .font(.headline)

                    Text(
                        selectedTheme == theme
                        ? "Currently equipped"
                        : "Ready to equip"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        selectedTheme == theme ? .green : .secondary
                    )
                }

                Spacer()

                Button {
                    equip(theme)
                } label: {

                    Text(
                        selectedTheme == theme
                        ? "Equipped"
                        : "Equip"
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme == theme ? .green : .purple)
                .disabled(selectedTheme == theme)
            }
        }
        .appCard(cornerRadius: 22)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onTapGesture {
            if selectedTheme != theme {
                equip(theme)
            }
        }
    }

    // MARK: - Preview

    @ViewBuilder
    private func themePreview(_ theme: String) -> some View {

        switch theme {

        case "outerspace":

            Image("OuterSpaceBackground")
                .resizable()
                .scaledToFill()

        case "sunset":

            LinearGradient(
                colors: [
                    .orange,
                    .pink,
                    .purple
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case "aurora":

            LinearGradient(
                colors: [
                    .mint,
                    .cyan,
                    .indigo
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case "rain_code":

            Image("RainCode")
                .resizable()
                .scaledToFill()

        default:

            LinearGradient(
                colors: [
                    .blue.opacity(0.45),
                    .purple.opacity(0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: - Owned Themes

    private var ownedThemes: [String] {

        backgrounds
            .split(separator: "|")
            .map(String.init)
    }

    private var savedEquippedTheme: String {
        UserDefaults.standard.string(forKey: "equippedBackground") ?? "default"
    }

    private func equip(_ theme: String) {
        // Write both ways so every view observing this key updates immediately.
        UserDefaults.standard.set(theme, forKey: "equippedBackground")
        UserDefaults.standard.synchronize()
        equippedBackground = theme
        selectedTheme = theme
        NotificationCenter.default.post(
            name: .productiveSpagettiThemeDidChange,
            object: theme
        )
    }

    // MARK: - Theme Names

    private func themeName(_ theme: String) -> String {

        switch theme {

        case "outerspace":
            return "Outer Space"

        case "sunset":
            return "Golden Hour"

        case "aurora":
            return "Aurora"

        case "rain_code":
            return "Rain Code"

        default:
            return "Default Gradient"
        }
    }
}

#Preview {
    BackgroundsView()
}

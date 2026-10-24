import Charts
import SwiftUI

struct ContentView: View {
    @AppStorage("first_time") private var first_time = true
    @AppStorage("score") private var score = 0
    @AppStorage("coins") private var coins = 0
    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("totalFocusMinutes") private var totalFocusMinutes = 0
    @AppStorage("lockpasscode") private var lockpasscode = ""

    @State private var showParentalControls = false
    @AppStorage("scoreHistory") private var scoreHistoryData = ""
    @AppStorage("info") private var info = ""
    @AppStorage("forChild") private var forChild = false
    @State private var parentalControlsUnlocked = false
    @State private var showingParentalPasscode = false
    @State private var parentalPasscode = ""
    @State private var parentalPasscodeError = ""
    @StateObject private var premium = PremiumManager.shared
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var welcomeSheet = false

    @State private var scoreHistory: [Int] = []

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("PRODUCTIVE SPAGETTI", systemImage: "sparkles")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.purple)
                                Text("Make today count.")
                                    .font(.largeTitle.bold())
                            }

                            Spacer()

                            NavigationLink(destination: ShopView()) {
                                Image(systemName: "bag.fill")
                                    .font(.title3)
                                    .padding(12)
                            }
                            .buttonStyle(.bordered)
                            NavigationLink(destination: statsView()) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.title3)
                                    .padding(12)
                            }
                            .buttonStyle(.bordered)
                            NavigationLink {
                                Settings()
                            } label: {
                                Image(systemName:"gear.circle.fill").font(.title3)
                                    .padding(12)
                            }.buttonStyle(.bordered)
                            // child
                            if forChild {
                                Button {
                                    parentalPasscode = ""
                                    parentalPasscodeError = ""
                                    showingParentalPasscode = true
                                } label: {
                                    Image(systemName: "figure.child.and.lock")
                                        .font(.title3)
                                        .padding(12)
                                }
                                .buttonStyle(.bordered)
                            }
                            // end child
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .firstTextBaseline) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Productivity score")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    Text("\(score)")
                                        .font(.system(size: 64, weight: .bold, design: .rounded))
                                        .foregroundStyle(.blue)
                                }
                                Spacer()
                                Image(systemName: "bolt.circle.fill")
                                    .font(.system(size: 46))
                                    .foregroundStyle(.yellow)
                            }

                            HStack(spacing: 10) {
                                metricPill(icon: "flame.fill", text: "\(currentStreak)-day streak", tint: .orange)
                                metricPill(icon: "clock.fill", text: formattedFocusTime, tint: .blue)
                                metricPill(icon: "circle.hexagongrid.fill", text: "\(coins)", tint: .purple)
                            }
                        }
                        .appCard()

                        NavigationLink(destination: PRView()) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start a productive run")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(18)
                            .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: TodoView()) {
                            Label("My To-Do List", systemImage: "checklist")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(.green.opacity(0.7))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Label("Score history", systemImage: "chart.line.uptrend.xyaxis")
                                    .font(.headline)
                                Spacer()
                                NavigationLink("All stats", destination: statsView())
                                    .font(.subheadline.weight(.semibold))
                            }

                            if scoreHistory.count > 1 {
                                Chart {
                                    ForEach(Array(scoreHistory.suffix(12).enumerated()), id: \.offset) { index, value in
                                        AreaMark(x: .value("Update", index), y: .value("Score", value))
                                            .foregroundStyle(.blue.opacity(0.15))
                                        LineMark(x: .value("Update", index), y: .value("Score", value))
                                            .foregroundStyle(.blue)
                                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                                    }
                                }
                                .chartXAxis(.hidden)
                                .chartYAxis(.hidden)
                                .frame(height: 150)
                            } else {
                                ContentUnavailableView("Your progress will appear here", systemImage: "chart.line.uptrend.xyaxis")
                                    .frame(height: 150)
                            }
                        }
                        .appCard()
                    }
                    .padding(28).foregroundStyle(.cyan)
                }
            }
            
            
            .task {
                await premium.loadProduct()
                await premium.refreshEntitlements()
            }
            
        }
        // child lock stuff
        .alert(
            "Parent Passcode",
            isPresented: $showingParentalPasscode
        ) {

            SecureField(
                "4-digit passcode",
                text: $parentalPasscode
            )

            Button("Cancel") {
                parentalPasscode = ""
                parentalPasscodeError = ""
            }

            Button("Unlock") {

                if parentalPasscode == lockpasscode {

                    parentalPasscode = ""
                    parentalPasscodeError = ""
                    showParentalControls = true

                } else {

                    parentalPasscodeError = "❌ Incorrect passcode."

                }
            }

        } message: {

            Text(
                parentalPasscodeError.isEmpty
                ? "Enter the parent passcode to continue."
                : parentalPasscodeError
            )
        }
        .sheet(isPresented: $showParentalControls) {
            ParentalControls()
        }
        .sheet(isPresented: $first_time) {
            WelcomeView()
        }
        .background(WindowCloseGuard())
        //end
        
        .onAppear {
            loadHistory()
            addCurrentScore()
        }
    }

    private func metricPill(icon: String, text: String, tint: Color) -> some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(tint.opacity(0.12), in: Capsule())
    }

    private var formattedFocusTime: String {
        let hours = totalFocusMinutes / 60
        let minutes = totalFocusMinutes % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    private func addCurrentScore() {
        guard scoreHistory.last != score else { return }
        scoreHistory.append(score)
        scoreHistory = Array(scoreHistory.suffix(30))
        scoreHistoryData = scoreHistory.map(String.init).joined(separator: ",")
    }

    private func loadHistory() {
        scoreHistory = scoreHistoryData.split(separator: ",").compactMap { Int($0) }
    }
}

struct WelcomeView: View {
    @AppStorage("first_time") private var first_time = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Productive Spagetti")
                    .font(.largeTitle.bold())

                NavigationLink {
                    welcomepg2()
                } label: {
                    Text("Get Started")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding()
        }
    }
}
struct welcomepg2: View {
    @State private var showTutorial = false
    @State private var finished = false
    @AppStorage("first_time") private var first_time = true

    var body: some View {
        VStack(spacing: 24) {
            Text("Need a tutorial?")
                .font(.largeTitle.bold())

            Text("We can quickly show you what the main buttons do.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            VStack(spacing: 14) {
                Button {
                    showTutorial = true
                } label: {
                    Text("Yes, show me")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    first_time = false
                } label: {
                    Text("No, I'll figure it out")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .frame(maxWidth: 350)

        }
        .padding(30)
        .sheet(isPresented: $showTutorial) {
            TutorialView()
        }
    }
}

struct TutorialView: View {
    @AppStorage("first_time") private var first_time = true
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    tutorialItem(
                        icon: "play.fill",
                        title: "Productive Run",
                        description: "Start a focus session and work toward increasing your productivity score."
                    )

                    tutorialItem(
                        icon: "bag.fill",
                        title: "Shop",
                        description: "Open the shop to spend your coins and manage Premium."
                    )

                    tutorialItem(
                        icon: "chart.bar.fill",
                        title: "Statistics",
                        description: "See your score, streaks, focus time, and score history."
                    )

                    tutorialItem(
                        icon: "gear.circle.fill",
                        title: "Settings",
                        description: "Change app settings and manage things like parental controls."
                    )

                    tutorialItem(
                        icon: "figure.child.and.lock",
                        title: "Parental Controls",
                        description: "Open parental controls when child mode is enabled."
                    )

                    tutorialItem(
                        icon: "sparkles",
                        title: "AI Productive Run",
                        description: "Use the AI-powered feature to help create a productive run."
                    )
                    Button("Done") {
                        first_time = false
                    }
                }
                .padding(24)
            }
            .navigationTitle("Tutorial")
        }
    }

    private func tutorialItem(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 35)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    welcomepg2()
}

#Preview {
    ContentView()
}

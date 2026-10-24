import Charts
import SwiftUI

struct statsView: View {

    @AppStorage("completedRuns") private var completedRuns = 0
    @AppStorage("totalFocusMinutes") private var totalFocusMinutes = 0
    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("longestStreak") private var longestStreak = 0
    @AppStorage("focusHistoryData") private var focusHistoryData = ""
    @AppStorage("blockedAppCountsData") private var blockedAppCountsData = Data()

    private var focusHistory: [Int] {
        focusHistoryData
            .split(separator: ",")
            .compactMap { Int($0) }
    }

    private var topDistractions: [(name: String, count: Int)] {
        let counts =
            (try? JSONDecoder().decode([String: Int].self,
                                       from: blockedAppCountsData)) ?? [:]

        return counts
            .map { (name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    var body: some View {

        NavigationStack {

            ZStack {

                LinearGradient(
                    colors: [
                        .blue.opacity(0.22),
                        .purple.opacity(0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {

                    VStack(alignment: .leading, spacing: 22) {

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Stats")
                                .font(.largeTitle.bold())

                            Text("A look at your focus habits")
                                .foregroundStyle(.secondary)
                        }

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 14
                        ) {

                            statCard(
                                title: "Focus Time",
                                value: formattedFocusTime,
                                icon: "clock.fill",
                                tint: .blue
                            )

                            statCard(
                                title: "Completed Runs",
                                value: "\(completedRuns)",
                                icon: "checkmark.circle.fill",
                                tint: .green
                            )

                            statCard(
                                title: "Current Streak",
                                value: "\(currentStreak) days",
                                icon: "flame.fill",
                                tint: .orange
                            )

                            statCard(
                                title: "Best Streak",
                                value: "\(longestStreak) days",
                                icon: "trophy.fill",
                                tint: .purple
                            )
                        }

                        VStack(alignment: .leading, spacing: 12) {

                            Label(
                                "Recent Focus Sessions",
                                systemImage: "chart.line.uptrend.xyaxis"
                            )
                            .font(.headline)

                            if focusHistory.isEmpty {

                                ContentUnavailableView(
                                    "No completed runs yet",
                                    systemImage: "chart.line.uptrend.xyaxis",
                                    description: Text(
                                        "Finish a productive run to add it to your chart."
                                    )
                                )
                                .frame(height: 220)

                            } else {

                                Chart {

                                    ForEach(
                                        Array(focusHistory.enumerated()),
                                        id: \.offset
                                    ) { index, minutes in

                                        AreaMark(
                                            x: .value("Session", index + 1),
                                            y: .value("Minutes", minutes)
                                        )
                                        .foregroundStyle(
                                            .purple.opacity(0.18)
                                        )

                                        LineMark(
                                            x: .value("Session", index + 1),
                                            y: .value("Minutes", minutes)
                                        )
                                        .foregroundStyle(.purple)
                                        .lineStyle(
                                            StrokeStyle(
                                                lineWidth: 3,
                                                lineCap: .round
                                            )
                                        )

                                        PointMark(
                                            x: .value("Session", index + 1),
                                            y: .value("Minutes", minutes)
                                        )
                                        .foregroundStyle(.purple)
                                    }
                                }
                                .chartYAxisLabel("Minutes")
                                .frame(height: 220)
                            }
                        }
                        .padding()
                        .background(.white.opacity(0.72))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 22)
                        )

                        VStack(alignment: .leading, spacing: 12) {

                            Label(
                                "Top Distractions",
                                systemImage: "apps.iphone"
                            )
                            .font(.headline)

                            if topDistractions.isEmpty {

                                Text("No blocked apps have been detected during a run yet.")
                                    .foregroundStyle(.secondary)

                            } else {

                                ForEach(
                                    Array(topDistractions.prefix(3).enumerated()),
                                    id: \.element.name
                                ) { index, app in

                                    HStack {

                                        Text("#\(index + 1)")
                                            .font(.headline.monospacedDigit())
                                            .foregroundStyle(.purple)
                                            .frame(width: 32)

                                        Text(app.name)

                                        Spacer()

                                        Text("\(app.count) detections")
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                        .padding()
                        .background(.white.opacity(0.72))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 22)
                        )

                        NavigationLink(destination: RunLog()) {

                            Label(
                                "View Run Log",
                                systemImage: "list.bullet.rectangle"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                    }
                    .padding(28)
                }
            }
        }
    }

    private var formattedFocusTime: String {

        let hours = totalFocusMinutes / 60
        let minutes = totalFocusMinutes % 60

        return hours > 0
            ? "\(hours)h \(minutes)m"
            : "\(minutes)m"
    }

    private func statCard(
        title: String,
        value: String,
        icon: String,
        tint: Color
    ) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(tint)

            Text(value)
                .font(.title2.bold())
                .lineLimit(1)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.72))
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
}

struct RunLog: View {

    @AppStorage("runlog") private var runlog = ""

    var body: some View {

        ZStack {

            Color.black
                .ignoresSafeArea()

            ScrollView {

                Text(runlog.isEmpty ? "No runs recorded yet." : runlog)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
    }
}

#Preview {
    statsView()
}

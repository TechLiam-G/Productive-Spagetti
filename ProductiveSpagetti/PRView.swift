import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct PRView: View {
    var initialAITask: String? = nil

    init(initialAITask: String? = nil) {
        self.initialAITask = initialAITask
    }
    let words = ["Why are you looking 😂","Wise man once said, 'Keep focusing!'","You got this!", "Never give up!", "This text changes!", "Yo... why are you still here","yayayayayaaaa","Prove that you are... um idk"]
    @AppStorage("achievements") private var achievements = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("lock_mode") private var lock_mode = false
    @AppStorage("equippedPet") private var equippedPet = ""
    @AppStorage("score") private var score = 0
    @AppStorage("blockedAppsData") private var blockedAppsData = ""
    @AppStorage("runlog") private var runlog = ""
    @AppStorage("equippedBackground") private var equippedBackground = "default"
    @AppStorage("blocker") private var blocker = false
    @AppStorage("completedRuns") private var completedRuns = 0
    @AppStorage("totalFocusMinutes") private var totalFocusMinutes = 0
    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("longestStreak") private var longestStreak = 0
    @AppStorage("lastCompletionTimestamp") private var lastCompletionTimestamp = 0.0
    @AppStorage("focusHistoryData") private var focusHistoryData = ""
    @AppStorage("blockedAppCountsData") private var blockedAppCountsData = Data()
    @AppStorage("focusGoal") private var focusGoal = ""
    @AppStorage("coins") private var coins = 0
    @AppStorage("autoBlockOnRun") private var autoBlockOnRun = false
    @State private var restoreBlockerAfterRun = false
    
    
    @State private var blockedApps: [String] = []
    
    @State private var showAIProductiveRun = false
    
    @State private var isRunning = false
    @State private var isPaused = false
    
    @State private var selectedMinutes = 25
    @State private var timeRemaining = 1500
    
    @State private var timer: Timer?
    @State private var lastPenaltyTime = Date.distantPast
    @State private var showCompletion = false
    
    var body: some View {
        
        ZStack {
            
            focusBackground
            
            
            VStack(spacing: 25) {
                
                
                Text("Productive Run")
                    .font(.largeTitle.bold())
                    .foregroundStyle(usesDarkFocusTheme ? .white : .primary)
                
                if isRunning{
                    Text(formatTime())
                        .font(.system(size: 70, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(usesDarkFocusTheme ? .white : .primary)
                }
                
                
                HStack {
                    
                    VStack {
                        Text("Score")
                            .font(.caption)
                        
                        Text("\(score)")
                            .font(.title.bold())
                    }
                    .frame(width: 120, height: 80)
                    .background(.white.opacity(0.7))
                    .cornerRadius(20)
                    
                    
                    VStack {
                        Text("Apps")
                            .font(.caption)
                        
                        Text("\(blockedApps.count)")
                            .font(.title.bold())
                    }
                    .frame(width: 120, height: 80)
                    .background(.white.opacity(0.7))
                    .cornerRadius(20)
                }
                
                Text(
                    (isRunning ?
                     (isPaused ? "⏸ Paused" : words.randomElement())
                     :
                        "") ?? ""
                )
                .font(.title3)
                .foregroundStyle(usesDarkFocusTheme ? .white : .primary)
                if isRunning && !equippedPet.isEmpty {

                    VStack(spacing: 8) {

                        if isRunning && equippedPet == "mini_spag" {
                            BouncingPetView()
                        }

                    }
                    .padding()
                    .background(.black.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                if isRunning {
                    ProgressView(value: runProgress)
                        .tint(usesDarkFocusTheme ? .white : .blue)
                        .frame(maxWidth: 360)

                    if !focusGoal.isEmpty {
                        Label(focusGoal, systemImage: "target")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(usesDarkFocusTheme ? .white : .primary)
                            .lineLimit(1)
                    }
                }
                
                
                
                if !isRunning {
                    
                    Stepper(
                        "Focus Time: \(selectedMinutes) min",
                        value: $selectedMinutes,
                        in: 1...180
                    )
                    .padding()
                    .background(.white.opacity(0.6))
                    .cornerRadius(15)

                    TextField("What are you focusing on? (optional)", text: $focusGoal)
                        .textFieldStyle(.roundedBorder).border(Color.white).clipShape(RoundedRectangle(cornerRadius: 15)).frame(maxWidth: .infinity, minHeight: 60, alignment: .init(horizontal: .leading, vertical: .center)).foregroundStyle(.secondary)
                    
                    
                    Button {
                        chooseApp()
                    } label: {
                        Label(
                            "Add Blocked App",
                            systemImage: "plus.app"
                        )
                    }
                    
                    
                    ScrollView {
                        VStack {
                            ForEach(blockedApps, id: \.self) { app in
                                
                                HStack {
                                    Text("🚫 \(app)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Button {
                                        removeApp(app)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.red)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(8)
                                .background(.red.opacity(0.15))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .frame(height: 120)
                    
                }
                
                
                
                HStack(spacing: 15) {
                    
                    if !isRunning {
                        
                        Button {
                            startRun()
                        } label: {
                            Label(
                                "Start",
                                systemImage: "play.fill"
                            )
                        }
                        .buttonStyle(.borderedProminent)
                        Button {
                            showAIProductiveRun = true
                        } label: {
                            Label(
                                "AI Recommendations",
                                systemImage: "sparkles"
                            )
                        }
                        .buttonStyle(.borderedProminent)
                        
                    } else {
                        
                        Button {
                            togglePause()
                        } label: {
                            Label(
                                isPaused ? "Resume" : "Pause",
                                systemImage:
                                    isPaused ? "play.fill" : "pause.fill"
                            )
                        }.disabled((lock_mode && PremiumManager.shared.isPremium))
                        
                        
                        Button {
                            stopRun()
                        } label: {
                            Label(
                                "Stop",
                                systemImage: "stop.fill"
                            )
                        }
                        .foregroundStyle(.red).disabled((lock_mode && PremiumManager.shared.isPremium))
                        .navigationBarBackButtonHidden(isRunning)
                    }
                }
            }
            .padding(40)
        }
        .onAppear {
            loadApps()

            if let initialAITask,
               !initialAITask.trimmingCharacters(
                   in: .whitespacesAndNewlines
               ).isEmpty {
                focusGoal = initialAITask
                showAIProductiveRun = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .productiveSpagettiThemeDidChange)) { notification in
            if let theme = notification.object as? String {
                equippedBackground = theme
            }
        }
        .alert("Run complete! +20 score", isPresented: $showCompletion) {
            Button("Nice work") { }
        } message: {
            Text("You completed a \(selectedMinutes)-minute focus session.")
        }
        .sheet(isPresented: $showAIProductiveRun) {
            AIProductiveRunView(
                initialTask: initialAITask ?? "",
                onAppsSelected: { apps in
                    for app in apps {
                        if !blockedApps.contains(app) {
                            blockedApps.append(app)
                        }
                    }

                    saveApps()

                    if !apps.isEmpty && PremiumManager.shared.isPremium {
                        blocker = true
                    }

                    startRun()
                }
            )
        }
    }
    
    func removeApp(_ app: String) {
        blockedApps.removeAll { $0 == app }
        saveApps()
    }
    
    func startRun() {
        
        timeRemaining = selectedMinutes * 60
        
        isRunning = true
        isPaused = false
        
        if autoBlockOnRun &&
            PremiumManager.shared.isPremium &&
            !blocker &&
            !blockedApps.isEmpty {

            restoreBlockerAfterRun = true
            blocker = true
        }
        
        // First run achievement
        if !achievements
            .split(separator: "|")
            .contains("First Time Runner") {
            
            addAchievement("First Time Runner")
        }
        
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { _ in
            
            if !isPaused {
                
                if timeRemaining <= 0 {
                    finishRun()
                    return
                }

                timeRemaining -= 1
                checkApps()

                if timeRemaining == 0 {
                    finishRun()
                }
            }
        }
    }
    
    
    
    func stopRun() {
        endRun()

        score = max(0, score - 20)
        runlog += "Run stopped -20 points\n"
    }
    
    
    func finishRun() {
        endRun()
        
        score += 2*selectedMinutes
        recordCompletedRun()
        
        if notificationsEnabled{
            NotificationManager.shared.sendReminder(
                title: "Run finished 🎉",
                body: "You have finished your run and earned +20 points!"
            )
        }
        // Achievement checks
        if completedRuns >= 10 {
            addAchievement("10 Focus Runs 🔥")
        }
        if completedRuns >= 100 {
            addAchievement("Been a long time 🔥")
        }

        if totalFocusMinutes >= 60 {
            addAchievement("1 Hour Focus Master ⏰")
        }
        if totalFocusMinutes >= 240 {
            addAchievement("Deep study mode ⏰")
        }

        if currentStreak >= 7 {
            addAchievement("7 Day Streak Champion 🏆")
        }

        if completedRuns.isMultiple(of: 3) {
            coins += 5
            runlog += "Three-run bonus +5 coins\n"
        }

        runlog += "Completed \(selectedMinutes)-minute run +20 points\n"
        showCompletion = true
    }

    func togglePause() {
        isPaused.toggle()

        if isPaused {
            score = max(0, score - 20)
            runlog += "Run paused -20 points\n"
        } else {
            runlog += "Run resumed\n"
        }
    }

    func endRun() {
        if restoreBlockerAfterRun {
            blocker = false
            restoreBlockerAfterRun = false
        }
        isRunning = false
        isPaused = false
        timer?.invalidate()
        timer = nil
    }
    
    
    
    func chooseApp() {
        
        let panel = NSOpenPanel()
        
        panel.title = "Choose Application"
        panel.allowedContentTypes = [
            UTType.application
        ]
        
        panel.allowsMultipleSelection = true
        
        
        if panel.runModal() == .OK {
            
            for url in panel.urls {
                
                let name =
                url.deletingPathExtension()
                    .lastPathComponent
                
                if !blockedApps.contains(name) {
                    blockedApps.append(name)
                    saveApps()
                }
            }
        }
    }
    func blockApp(_ appName: String) {
        print("🚫 Blocking \(appName)")

        Task { @MainActor in
            BlockOverlayController.shared.show(blockedApp: appName)
        }
    }
    
    
    func checkApps() {
        guard isRunning else {
            BlockOverlayController.shared.hide()
            return
        }

        guard blocker && PremiumManager.shared.isPremium else {
            BlockOverlayController.shared.hide()
            return
        }

        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return
        }

        // Productive Spagetti itself is not blocked.
        if frontmostApp.bundleIdentifier == Bundle.main.bundleIdentifier {
            BlockOverlayController.shared.hide()
            return
        }

        guard let appName = frontmostApp.localizedName else {
            return
        }

        // If the current app isn't blocked, remove the overlay.
        if !blockedApps.contains(appName) {
            BlockOverlayController.shared.hide()
            return
        }

        // The current app IS blocked.
        if Date().timeIntervalSince(lastPenaltyTime) > 30 {
            score = max(0, score - 5)

            lastPenaltyTime = Date()

            recordBlockedAppDetection(appName)

            runlog += "⚠️ \(appName) opened -5 points\n"

            print("⚠️ \(appName) detected -5")
        }

        blockApp(appName)
    }
    
    
    
    func saveApps() {
        blockedAppsData =
        blockedApps.joined(separator: "|")
    }
    
    
    func loadApps() {
        
        if !blockedAppsData.isEmpty {
            blockedApps =
            blockedAppsData.split(separator: "|")
                .map(String.init)
        }
    }
    
    
    
    func formatTime() -> String {
        
        let min = timeRemaining / 60
        let sec = timeRemaining % 60
        
        return String(
            format: "%02d:%02d",
            min,
            sec
        )
    }

    private var usesDarkFocusTheme: Bool { isRunning }

    private var runProgress: Double {
        let totalSeconds = Double(selectedMinutes * 60)
        guard totalSeconds > 0 else { return 0 }
        return 1 - Double(timeRemaining) / totalSeconds
    }

    @ViewBuilder
    private var focusBackground: some View {
        switch isRunning ? equippedBackground : "default" {
        case "outerspace":
            Image("OuterSpaceBackground").resizable().scaledToFill().ignoresSafeArea()
            Color.black.opacity(0.38).ignoresSafeArea()
        case "sunset":
            LinearGradient(colors: [.orange.opacity(0.65), .pink.opacity(0.6), .purple.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            Color.black.opacity(0.32).ignoresSafeArea()
        case "aurora":
            LinearGradient(colors: [.mint.opacity(0.55), .cyan.opacity(0.5), .indigo.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            Color.black.opacity(0.32).ignoresSafeArea()
        case "rain_code":
            Image("RainCode").resizable().scaledToFit().ignoresSafeArea()
            Color.black.opacity(0.38).ignoresSafeArea()
        default:
            LinearGradient(
                colors: [
                    Color(red: 0.30, green: 0.45, blue: 0.1),
                    Color(red: 1, green: 1, blue: 0.75)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    private func recordCompletedRun() {
        completedRuns += 1
        totalFocusMinutes += selectedMinutes

        var history = focusHistoryData
            .split(separator: ",")
            .compactMap { Int($0) }
        history.append(selectedMinutes)
        focusHistoryData = history.suffix(14).map(String.init).joined(separator: ",")

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if lastCompletionTimestamp == 0 {
            currentStreak = 1
        } else {
            let previousDay = calendar.startOfDay(for: Date(timeIntervalSince1970: lastCompletionTimestamp))
            let daysBetween = calendar.dateComponents([.day], from: previousDay, to: today).day ?? 0

            if daysBetween == 1 {
                currentStreak += 1
            } else if daysBetween > 1 {
                currentStreak = 1
            }
        }

        longestStreak = max(longestStreak, currentStreak)
        lastCompletionTimestamp = today.timeIntervalSince1970
    }

    private func recordBlockedAppDetection(_ appName: String) {
        var counts = (try? JSONDecoder().decode([String: Int].self, from: blockedAppCountsData)) ?? [:]
        counts[appName, default: 0] += 1
        blockedAppCountsData = (try? JSONEncoder().encode(counts)) ?? Data()
    }
    func addAchievement(_ name: String) {
        let currentAchievements = achievements
            .split(separator: "|")
            .map(String.init)

        if !currentAchievements.contains(name) {
            if achievements.isEmpty {
                achievements = name
            } else {
                achievements += "|\(name)"
            }
        }
    }
}
struct BouncingPetView: View {

    @State private var isBouncing = false

    var body: some View {
        VStack(spacing: 8) {
            Text("Mini Spagetti (the cringest dog)")
                .font(.headline)
                .foregroundStyle(.white)
            Image(systemName: "dog.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
                .offset(y: isBouncing ? -12 : 0)


        }
        .padding()
        .background(.black.opacity(0.25))
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
            ) {
                isBouncing = true
            }
        }
    }
}
struct BlockedAppOverlayView: View {
    let appName: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.08, green: 0.08, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.white)

                Text("App Blocked")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)

                Text(appName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))

                Text("This app is blocked during your Productive Run.")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                HStack{
                    Text("To exit this app, hit ")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.6))
                    Image(systemName: "command.square").font(.headline)
                        .foregroundStyle(.white.opacity(0.6))
                    Text(" + ")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.6))
                    Image(systemName: "q.square").font(.headline)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(50)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

import SwiftUI
import AppKit

@MainActor
final class BlockOverlayController {
    static let shared = BlockOverlayController()

    private var window: NSPanel?

    private init() {}

    func show(blockedApp: String) {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return
        }

        let pid = app.processIdentifier

        guard let windowInfo = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]]
        else {
            return
        }

        var targetFrame: CGRect?

        for info in windowInfo {
            guard let ownerPID = info[kCGWindowOwnerPID as String] as? Int32,
                  ownerPID == pid
            else {
                continue
            }

            guard let boundsValue = info[kCGWindowBounds as String],
                  let boundsDict = boundsValue as? NSDictionary
            else {
                continue
            }

            var bounds = CGRect.zero

            if CGRectMakeWithDictionaryRepresentation(
                boundsDict,
                &bounds
            ) {
                if bounds.width > 300 && bounds.height > 200 {
                    targetFrame = bounds
                    break
                }
            }
        }

        guard let cgFrame = targetFrame else {
            print("⚠️ Could not find window for \(blockedApp)")
            return
        }

        guard let screen = NSScreen.main else {
            return
        }

        let convertedFrame = CGRect(
            x: cgFrame.origin.x,
            y: screen.frame.height - cgFrame.origin.y - cgFrame.height,
            width: cgFrame.width,
            height: cgFrame.height
        )

        let overlayView = BlockedAppOverlayView(
            appName: blockedApp
        )

        if let existingWindow = window {
            existingWindow.setFrame(
                convertedFrame,
                display: true,
                animate: false
            )

            if let hostingView = existingWindow.contentView
                as? NSHostingView<BlockedAppOverlayView> {
                hostingView.rootView = overlayView
            }

            existingWindow.orderFrontRegardless()
            return
        }

        let hostingView = NSHostingView(
            rootView: overlayView
        )

        let newWindow = NSPanel(
            contentRect: convertedFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        newWindow.contentView = hostingView
        newWindow.isOpaque = true
        newWindow.backgroundColor = .black
        newWindow.level = .screenSaver

        newWindow.collectionBehavior = [
            .canJoinAllSpaces,
            .canJoinAllApplications,
            .fullScreenAuxiliary,
            .stationary
        ]

        newWindow.hidesOnDeactivate = false
        newWindow.ignoresMouseEvents = false
        newWindow.hasShadow = false

        window = newWindow

        newWindow.orderFrontRegardless()
    }

    func hide() {
        window?.orderOut(nil)
    }
}



#Preview {
    PRView()
}

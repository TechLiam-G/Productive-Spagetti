//
//  AIProductiveRunView.swift
//  ProductiveSpagetti
//
//  Created by Liam Gao on 8/18/26.
//

import SwiftUI

struct AIProductiveRunView: View {

    @Environment(\.dismiss) private var dismiss

    // send apps to PR view
    let onAppsSelected: ([String]) -> Void

    @State private var task: String
    @State private var didReceiveSuggestions = false
    @State private var didAutoAsk = false
    @State private var suggestedApps: [String] = []
    @State private var selectedApps: Set<String> = []

    @State private var isAskingAI = false
    @State private var errorMessage = ""
    init(
        initialTask: String = "",
        onAppsSelected: @escaping ([String]) -> Void
    ) {
        self.onAppsSelected = onAppsSelected
        _task = State(initialValue: initialTask)
    }

    var body: some View {

        VStack(spacing: 20) {

            Text("AI Productive Run")
                .font(.largeTitle.bold())

            Text("What are you working on?")
                .font(.title3)

            TextField(
                "Example: I'm coding a Minecraft mod",
                text: $task
            )
            .textFieldStyle(.roundedBorder)
            .frame(maxWidth: 500)

            Button {
                askAI()
            } label: {

                Label(
                    isAskingAI ? "Thinking..." : "Find Distracting Apps",
                    systemImage: "sparkles"
                )
            }
            .buttonStyle(.borderedProminent)
            .disabled(
                task.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty || isAskingAI
            )

            if isAskingAI {
                ProgressView("AI is thinking...")
            }

            if !suggestedApps.isEmpty {

                Text("AI Suggestions")
                    .font(.headline)

                Text("Uncheck anything you want to keep available.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                List(suggestedApps, id: \.self) { app in
                    Toggle(
                        isOn: Binding(
                            get: {
                                selectedApps.contains(app)
                            },
                            set: { isSelected in
                                if isSelected {
                                    selectedApps.insert(app)
                                } else {
                                    selectedApps.remove(app)
                                }
                            }
                        )
                    ) {
                        HStack {
                            Image(systemName: "app.fill")
                            Text(app)
                        }
                    }
                    .toggleStyle(.checkbox)
                }
            }

            if !errorMessage.isEmpty {

                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            HStack(spacing: 12) {

                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)

                if didReceiveSuggestions {

                    Button("Use These Apps") {

                        let apps = Array(selectedApps)

                        onAppsSelected(apps)

                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedApps.isEmpty)
                }
            }
        }
        .padding(30)
        .frame(
            minWidth: 600,
            minHeight: 550
        )
        .onAppear {
            guard !didAutoAsk,
                  !task.trimmingCharacters(
                      in: .whitespacesAndNewlines
                  ).isEmpty else {
                return
            }

            didAutoAsk = true
            askAI()
        }
    }

    // MARK: - Ask AI

    private func askAI() {

        isAskingAI = true
        errorMessage = ""
        suggestedApps = []
        selectedApps.removeAll()
        didReceiveSuggestions = false

        Task {

            do {

                // Get apps installed on this Mac
                let installedApps =
                    InstalledAppsManager.shared
                    .getInstalledApps()

                let appNames = installedApps.map {
                    $0.name
                }

                print("🤖 Task:", task)
                print("📱 Apps:", appNames)

                let result =
                    try await AIProductiveRunManager.shared.askAI(
                        task: task,
                        apps: appNames
                    )

                await MainActor.run {

                    suggestedApps = result

                    // Select everything AI suggested by default
                    selectedApps = Set(result)

                    isAskingAI = false
                    didReceiveSuggestions = true
                }

                print("🤖 AI suggested:", result)

            } catch {

                await MainActor.run {

                    isAskingAI = false

                    errorMessage =
                        "AI request failed: \(error.localizedDescription)"
                }

                print(
                    "❌ AI request failed:",
                    error
                )
            }
        }
    }
}

#Preview {
    AIProductiveRunView(
        initialTask: "",
        onAppsSelected: { apps in
            print("Selected apps:", apps)
        }
    )
}

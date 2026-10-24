import Foundation
import SwiftUI

struct TodoTask: Identifiable, Codable , Equatable{
    var id = UUID()
    var title: String
    var isCompleted = false
}

struct TodoView: View {
    @AppStorage("todoTasksData") private var todoTasksData = ""
    @AppStorage("focusGoal") private var focusGoal = ""

    @State private var tasks: [TodoTask] = []
    @State private var newTask = ""
    @State private var startFocus = false
    @State private var selectedTaskForFocus = ""

    private var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }

    private var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedCount) / Double(tasks.count)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.96, blue: 1.0),
                    Color(red: 0.90, green: 0.91, blue: 1.0),
                    Color(red: 0.97, green: 0.93, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(
                                "PRODUCTIVE SPAGETTI TODO",
                                systemImage: "sparkles"
                            )
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.purple)

                            Text("My Tasks")
                                .font(.system(size: 34, weight: .bold))

                            Text("Make a plan. Focus. Get things done.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "checklist")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 68, height: 68)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(
                                    cornerRadius: 22,
                                    style: .continuous
                                )
                            )
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Your progress")
                                    .font(.headline)

                                Text(
                                    tasks.isEmpty
                                    ? "Add your first task to get started."
                                    : "\(completedCount) of \(tasks.count) tasks completed"
                                )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.purple)
                        }

                        ProgressView(value: progress)
                            .tint(.purple)
                            .scaleEffect(x: 1, y: 1.5, anchor: .center)

                        HStack(spacing: 12) {
                            progressStat(
                                title: "To do",
                                value: "\(tasks.count - completedCount)",
                                icon: "circle",
                                color: .blue
                            )

                            progressStat(
                                title: "Completed",
                                value: "\(completedCount)",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )

                            progressStat(
                                title: "Total",
                                value: "\(tasks.count)",
                                icon: "list.bullet",
                                color: .purple
                            )
                        }
                    }
                    .padding(22)
                    .background(.white.opacity(0.85))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 22,
                            style: .continuous
                        )
                    )
                    .shadow(
                        color: .black.opacity(0.04),
                        radius: 12,
                        y: 5
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add a task")
                            .font(.headline)

                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.purple)

                            TextField(
                                "What do you need to do?",
                                text: $newTask
                            )
                            .textFieldStyle(.plain)
                            .onSubmit {
                                addTask()
                            }

                            Button {
                                addTask()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(width: 38, height: 38)
                                    .background(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        in: RoundedRectangle(
                                            cornerRadius: 12
                                        )
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(
                                newTask.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ).isEmpty
                            )
                            .opacity(
                                newTask.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ).isEmpty ? 0.5 : 1
                            )
                        }
                        .padding(14)
                        .background(.white)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            )
                        )
                    }

                    HStack {
                        Text("Your list")
                            .font(.title2.bold())

                        Spacer()

                        if !tasks.isEmpty {
                            Text("\(tasks.count) tasks")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }

                    if tasks.isEmpty {
                        VStack(spacing: 14) {
                            Image(systemName: "checklist")
                                .font(.system(size: 38))
                                .foregroundStyle(.purple)

                            Text("Ready to get things done?")
                                .font(.headline)

                            Text("Your tasks will appear here after you add them.")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .padding(.horizontal, 20)
                        .background(.white.opacity(0.75))
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 22,
                                style: .continuous
                            )
                        )
                    } else {
                        VStack(spacing: 12) {
                            ForEach(tasks) { task in
                                taskRow(task)
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: tasks)
                    }

                    if completedCount > 0 {
                        Button {
                            tasks.removeAll { $0.isCompleted }
                            saveTasks()
                        } label: {
                            Label(
                                "Clear completed tasks",
                                systemImage: "trash"
                            )
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(28)
                .frame(maxWidth: 850)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(minWidth: 550, minHeight: 500)
        .navigationTitle("To-Do List")
        .navigationDestination(isPresented: $startFocus) {
            PRView(initialAITask: selectedTaskForFocus)
        }
        .onAppear {
            loadTasks()
        }
    }

    private func progressStat(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title2.bold())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.08))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )
        )
    }

    private func taskRow(_ task: TodoTask) -> some View {
        HStack(spacing: 14) {
            Button {
                toggleTask(task)
            } label: {
                Image(
                    systemName: task.isCompleted
                    ? "checkmark.circle.fill"
                    : "circle"
                )
                .font(.title2)
                .foregroundStyle(
                    task.isCompleted ? .green : .gray.opacity(0.65)
                )
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 5) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(
                        task.isCompleted ? .secondary : .primary
                    )

                Text(task.isCompleted ? "Completed" : "Ready when you are")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Button {
                selectedTaskForFocus = task.title
                focusGoal = task.title
                startFocus = true
            } label: {
                Label("Focus", systemImage: "play.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 9)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
            }
            .buttonStyle(.plain)
            .disabled(task.isCompleted)
            .opacity(task.isCompleted ? 0.4 : 1)

            Button {
                deleteTask(task)
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundStyle(.red.opacity(0.8))
                    .frame(width: 30, height: 34)
            }
            .buttonStyle(.plain)
        }
        .padding(15)
        .background(.white.opacity(0.9))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .stroke(
                task.isCompleted
                ? Color.green.opacity(0.25)
                : Color.white.opacity(0.8),
                lineWidth: 1
            )
        }
    }

    private func addTask() {
        let title = newTask.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !title.isEmpty else { return }

        tasks.append(TodoTask(title: title))
        newTask = ""
        saveTasks()
    }

    private func toggleTask(_ task: TodoTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        tasks[index].isCompleted.toggle()
        saveTasks()
    }

    private func deleteTask(_ task: TodoTask) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }

    private func loadTasks() {
        guard let data = todoTasksData.data(using: .utf8),
              let savedTasks = try? JSONDecoder().decode(
                [TodoTask].self,
                from: data
              ) else {
            return
        }

        tasks = savedTasks
    }

    private func saveTasks() {
        guard let data = try? JSONEncoder().encode(tasks),
              let json = String(data: data, encoding: .utf8) else {
            return
        }

        todoTasksData = json
    }
}

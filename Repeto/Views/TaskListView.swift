//
//  TaskListView.swift
//  Repeto
//
//  Created by Claude on 2025/12/20.
//

import CoreData
import SwiftUI

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var viewModel: TaskListViewModel
    @State private var showingTaskForm = false
    @State private var showingEditForm = false
    @State private var taskToEdit: Task?
    @State private var hapticTrigger = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.nextReminderAt, ascending: true)],
        predicate: NSPredicate(format: "isArchived == NO"),
        animation: .default
    )
    private var tasks: FetchedResults<Task>

    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = State(wrappedValue: TaskListViewModel(context: context))
    }

    var body: some View {
        NavigationView {
            Group {
                if tasks.isEmpty {
                    emptyStateView
                } else {
                    taskListView
                }
            }
            .navigationTitle("Repeto")
            .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingTaskForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("タスクを追加")
                }
            }
            .sheet(isPresented: $showingTaskForm) {
                TaskFormView(context: viewContext)
            }
            .sheet(isPresented: $showingEditForm) {
                if let task = taskToEdit {
                    TaskFormView(context: viewContext, task: task)
                }
            }
            .alert("エラー", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.spacing(.lg)) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: DesignSystem.iconSize(.lg)))
                .foregroundStyle(.accent)

            Text("タスクがありません")
                .font(.title2)
                .fontWeight(.semibold)

            Text("+ ボタンから新しいタスクを追加しましょう")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Task List

    private var taskListView: some View {
        List {
            let overdueTasks = tasks.filter { $0.isOverdue }
            if !overdueTasks.isEmpty {
                Section("期限切れ") {
                    ForEach(overdueTasks, id: \.objectID) { taskRow(for: $0) }
                }
            }

            let todayTasks = tasks.filter { $0.isToday }
            if !todayTasks.isEmpty {
                Section("今日") {
                    ForEach(todayTasks, id: \.objectID) { taskRow(for: $0) }
                }
            }

            let upcomingTasks = tasks.filter { $0.isUpcoming }
            if !upcomingTasks.isEmpty {
                Section("今後") {
                    ForEach(upcomingTasks, id: \.objectID) { taskRow(for: $0) }
                }
            }
        }
    }

    // MARK: - Task Row

    @ViewBuilder
    private func taskRow(for task: Task) -> some View {
        TaskRowView(task: task)
            .contentShape(Rectangle())
            .onTapGesture { completeTask(task) }
            .accessibilityLabel(task.displayName)
            .accessibilityHint("タップして完了")
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    deleteTask(task)
                } label: {
                    Label("削除", systemImage: "trash")
                }

                Button {
                    editTask(task)
                } label: {
                    Label("編集", systemImage: "pencil")
                }
                .tint(.blue)
            }
    }

    // MARK: - Actions

    private func completeTask(_ task: Task) {
        hapticTrigger.toggle()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            viewModel.completeTask(task)
        }
    }

    private func deleteTask(_ task: Task) {
        withAnimation { viewModel.deleteTask(task) }
    }

    private func editTask(_ task: Task) {
        taskToEdit = task
        showingEditForm = true
    }
}

#Preview("Empty State") {
    TaskListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

#Preview("With Tasks") {
    let context = PersistenceController.preview.container.viewContext

    let overdueTask = Task(context: context)
    overdueTask.id = UUID()
    overdueTask.name = "部屋の掃除"
    overdueTask.intervalDays = 7
    overdueTask.nextReminderAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())
    overdueTask.createdAt = Date()
    overdueTask.isArchived = false

    let todayTask = Task(context: context)
    todayTask.id = UUID()
    todayTask.name = "食材の買い出し"
    todayTask.intervalDays = 3
    todayTask.nextReminderAt = Date()
    todayTask.createdAt = Date()
    todayTask.isArchived = false

    let upcomingTask = Task(context: context)
    upcomingTask.id = UUID()
    upcomingTask.name = "ゴミ出し"
    upcomingTask.intervalDays = 1
    upcomingTask.nextReminderAt = Calendar.current.date(byAdding: .day, value: 2, to: Date())
    upcomingTask.createdAt = Date()
    upcomingTask.isArchived = false

    return TaskListView()
        .environment(\.managedObjectContext, context)
}

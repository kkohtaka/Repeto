//
//  TaskFormView.swift
//  Repeto
//
//  Created by Claude on 2025/12/20.
//

import CoreData
import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TaskFormViewModel
    @State private var showError = false
    @State private var errorMessage: String?
    // Scales with Dynamic Type so the interval field does not clip at larger text sizes.
    @ScaledMetric(relativeTo: .body) private var intervalFieldWidth: CGFloat = 80

    init(context: NSManagedObjectContext, task: Task? = nil) {
        _viewModel = State(wrappedValue: TaskFormViewModel(context: context, task: task))
    }

    var body: some View {
        NavigationView {
            Form {
                taskNameSection
                intervalSection
                nextReminderSection
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                        .accessibilityLabel("キャンセル")
                        .accessibilityHint("編集を破棄して閉じます")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.saveButtonTitle) { saveTask() }
                        .accessibilityLabel(viewModel.saveButtonTitle)
                        .accessibilityHint("入力内容を保存します")
                }
            }
            .alert("エラー", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage { Text(errorMessage) }
            }
        }
    }

    // MARK: - Sections

    private var taskNameSection: some View {
        Section {
            TextField("タスク名", text: $viewModel.name)
                .textInputAutocapitalization(.never)
                .accessibilityLabel("タスク名")
                .accessibilityHint("繰り返したいタスクの名前を入力します")
            if let error = viewModel.nameError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.destructive)
            }
        } header: {
            Text("タスク名")
        } footer: {
            Text("例: 部屋の掃除、食材の買い出し")
        }
    }

    private var intervalSection: some View {
        Section {
            HStack {
                TextField("インターバル", text: $viewModel.intervalDays)
                    .keyboardType(.numberPad)
                    .frame(width: intervalFieldWidth)
                    .accessibilityLabel("インターバル")
                    .accessibilityHint("タスクを繰り返す間隔を日数で入力します")
                Text("日ごと")
                    .foregroundStyle(.secondary)
            }
            if let error = viewModel.intervalError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.destructive)
            }
        } header: {
            Text("インターバル")
        } footer: {
            Text("タスクを繰り返す間隔（日数）を入力してください")
        }
    }

    private var nextReminderSection: some View {
        Section {
            DatePicker(
                "次回リマインド日",
                selection: $viewModel.nextReminderDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .accessibilityLabel("次回リマインド日時")
            .accessibilityHint("次回のリマインド通知日時を設定します")
        } header: {
            Text("次回リマインド日時")
        } footer: {
            Text("次回のリマインド通知日時を設定してください")
        }
    }

    // MARK: - Actions

    private func saveTask() {
        do {
            try viewModel.save()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview("Create Task") {
    TaskFormView(context: PersistenceController.preview.container.viewContext)
}

#Preview("Edit Task") {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context)
    task.id = UUID()
    task.name = "部屋の掃除"
    task.intervalDays = 7
    task.nextReminderAt = Date()
    task.createdAt = Date()
    return TaskFormView(context: context, task: task)
}

#Preview("Create - Dark / Accessibility Text") {
    TaskFormView(context: PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}

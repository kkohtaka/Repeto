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
    @StateObject private var viewModel: TaskFormViewModel
    @State private var showError = false
    @State private var errorMessage: String?

    init(context: NSManagedObjectContext, task: Task? = nil) {
        _viewModel = StateObject(wrappedValue: TaskFormViewModel(context: context, task: task))
    }

    var body: some View {
        NavigationView {
            Form {
                // Task Name Section
                Section {
                    TextField("タスク名", text: $viewModel.name)
                        .textInputAutocapitalization(.never)

                    if let error = viewModel.nameError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("タスク名")
                } footer: {
                    Text("例: 部屋の掃除、食材の買い出し")
                }

                // Interval Section
                Section {
                    HStack {
                        TextField("インターバル", text: $viewModel.intervalDays)
                            .keyboardType(.numberPad)
                            .frame(width: 80)

                        Text("日ごと")
                            .foregroundColor(.secondary)
                    }

                    if let error = viewModel.intervalError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("インターバル")
                } footer: {
                    Text("タスクを繰り返す間隔（日数）を入力してください")
                }

                // Next Reminder Section
                Section {
                    DatePicker(
                        "次回リマインド日",
                        selection: $viewModel.nextReminderDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                } header: {
                    Text("次回リマインド日時")
                } footer: {
                    Text("次回のリマインド通知日時を設定してください")
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.saveButtonTitle) {
                        saveTask()
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .alert("エラー", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
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
    let context = PersistenceController.preview.container.viewContext
    return TaskFormView(context: context)
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

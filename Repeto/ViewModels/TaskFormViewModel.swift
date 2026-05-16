//
//  TaskFormViewModel.swift
//  Repeto
//
//  Created by Claude on 2025/12/20.
//

import CoreData
import Foundation
import Observation

@MainActor
@Observable
final class TaskFormViewModel {
    private let taskService: TaskService
    private let task: Task?

    var name: String = ""
    var intervalDays: String = "7"
    var nextReminderDate: Date = Date()
    var nameError: String?
    var intervalError: String?

    var isEditMode: Bool { task != nil }
    var title: String { isEditMode ? "タスク編集" : "新しいタスク" }
    var saveButtonTitle: String { isEditMode ? "更新" : "作成" }

    init(context: NSManagedObjectContext, task: Task? = nil) {
        self.taskService = TaskService(context: context)
        self.task = task

        if let task {
            self.name = task.name ?? ""
            self.intervalDays = "\(task.intervalDays)"
            self.nextReminderDate = task.nextReminderAt ?? Date()
        }
    }

    // MARK: - Save

    func save() throws {
        guard validate() else { return }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let interval = Int32(intervalDays) else {
            throw ValidationError.invalidInterval
        }

        if let task {
            try taskService.updateTask(
                task,
                name: trimmedName,
                intervalDays: interval,
                nextReminderAt: nextReminderDate
            )
        } else {
            try taskService.createTask(
                name: trimmedName,
                intervalDays: interval,
                nextReminderAt: nextReminderDate
            )
        }
    }

    // MARK: - Validation

    private func validate() -> Bool {
        var isValid = true

        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            nameError = "タスク名を入力してください"
            isValid = false
        } else {
            nameError = nil
        }

        if let interval = Int32(intervalDays), interval >= 1 {
            intervalError = nil
        } else {
            intervalError = "1以上の数値を入力してください"
            isValid = false
        }

        return isValid
    }

    enum ValidationError: LocalizedError {
        case invalidInterval

        var errorDescription: String? {
            switch self {
            case .invalidInterval: "インターバルの値が不正です"
            }
        }
    }
}

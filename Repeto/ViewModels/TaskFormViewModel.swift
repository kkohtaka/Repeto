//
//  TaskFormViewModel.swift
//  Repeto
//
//  Created by Claude on 2025/12/20.
//

import CoreData
import Foundation
import SwiftUI

@MainActor
final class TaskFormViewModel: ObservableObject {
    private let taskService: TaskService
    private let task: Task?

    // Form fields
    @Published var name: String = ""
    @Published var intervalDays: String = "7"
    @Published var nextReminderDate: Date = Date()

    // Validation
    @Published var nameError: String?
    @Published var intervalError: String?

    // State
    @Published var isSaving = false

    var isEditMode: Bool {
        task != nil
    }

    var title: String {
        isEditMode ? "タスク編集" : "新しいタスク"
    }

    var saveButtonTitle: String {
        isEditMode ? "更新" : "作成"
    }

    init(context: NSManagedObjectContext, task: Task? = nil) {
        self.taskService = TaskService(context: context)
        self.task = task

        // Pre-fill form if editing
        if let task = task {
            self.name = task.name ?? ""
            self.intervalDays = "\(task.intervalDays)"
            self.nextReminderDate = task.nextReminderAt ?? Date()
        }
    }

    // MARK: - Validation

    func validate() -> Bool {
        var isValid = true

        // Validate name
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            nameError = "タスク名を入力してください"
            isValid = false
        } else {
            nameError = nil
        }

        // Validate interval
        if let interval = Int32(intervalDays), interval >= 1 {
            intervalError = nil
        } else {
            intervalError = "1以上の数値を入力してください"
            isValid = false
        }

        return isValid
    }

    // MARK: - Save

    func save() throws {
        guard validate() else {
            return
        }

        isSaving = true
        defer { isSaving = false }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let interval = Int32(intervalDays) else {
            throw ValidationError.invalidInterval
        }

        if let task = task {
            // Update existing task
            task.name = trimmedName
            task.intervalDays = interval
            task.nextReminderAt = nextReminderDate
            try taskService.updateTask(task)
        } else {
            // Create new task
            try taskService.createTask(
                name: trimmedName,
                intervalDays: interval,
                nextReminderAt: nextReminderDate
            )
        }
    }

    enum ValidationError: LocalizedError {
        case invalidInterval

        var errorDescription: String? {
            switch self {
            case .invalidInterval:
                return "インターバルの値が不正です"
            }
        }
    }
}

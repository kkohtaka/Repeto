//
//  TaskListViewModel.swift
//  Repeto
//
//  Created by Claude on 2025/12/20.
//

import CoreData
import Foundation
import SwiftUI

@MainActor
final class TaskListViewModel: ObservableObject {
    private let taskService: TaskService
    @Published var errorMessage: String?
    @Published var showError = false

    init(context: NSManagedObjectContext) {
        self.taskService = TaskService(context: context)
    }

    // MARK: - Task Operations

    /// Fetches all active tasks grouped by status
    func fetchGroupedTasks() throws -> GroupedTasks {
        try taskService.fetchTasksGrouped()
    }

    /// Returns the total count of active tasks
    func activeTaskCount() throws -> Int {
        try taskService.activeTaskCount()
    }

    /// Returns the count of overdue tasks
    func overdueTaskCount() throws -> Int {
        try taskService.overdueTaskCount()
    }

    // MARK: - Task Completion

    /// Marks a task as completed and calculates next reminder date
    /// - Parameter task: The task to complete
    func completeTask(_ task: Task) {
        do {
            try taskService.completeTask(task)
        } catch {
            handleError(error)
        }
    }

    /// Deletes a task
    /// - Parameter task: The task to delete
    func deleteTask(_ task: Task) {
        do {
            try taskService.deleteTask(task)
        } catch {
            handleError(error)
        }
    }

    // MARK: - Error Handling

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

//
//  TaskListViewModel.swift
//  Repeto
//
//  Created by Claude on 2025/12/20.
//

import CoreData
import Foundation
import Observation

@MainActor
@Observable
final class TaskListViewModel {
    private let taskService: TaskService
    var errorMessage: String?
    var showError = false

    init(context: NSManagedObjectContext) {
        self.taskService = TaskService(context: context)
    }

    // MARK: - Task Operations

    func completeTask(_ task: Task) {
        do {
            try taskService.completeTask(task)
        } catch {
            handleError(error)
        }
    }

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

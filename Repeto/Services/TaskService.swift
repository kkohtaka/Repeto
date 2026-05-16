//
//  TaskService.swift
//  Repeto
//
//  Created by Claude on 2025/12/07.
//

import CoreData
import Foundation

/// Service for managing Task entities with CRUD operations and interval calculations
@MainActor
final class TaskService {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    // MARK: - Create

    /// Creates a new task with the specified parameters.
    /// - Parameters:
    ///   - name: The name of the task
    ///   - intervalDays: The interval in days between reminders
    ///   - nextReminderAt: Next reminder date. Defaults to current date + interval if nil
    @discardableResult
    func createTask(
        name: String,
        intervalDays: Int32,
        nextReminderAt: Date? = nil
    ) throws -> Task {
        let task = Task(context: viewContext)
        task.id = UUID()
        task.name = name
        task.intervalDays = intervalDays
        task.createdAt = Date()
        task.updatedAt = Date()
        task.isArchived = false
        task.nextReminderAt = nextReminderAt ?? calculateNextReminderDate(
            from: Date(),
            intervalDays: intervalDays
        )
        try viewContext.save()
        return task
    }

    // MARK: - Update

    /// Updates an existing task's editable fields.
    /// - Parameters:
    ///   - task: The task to update
    ///   - name: New task name
    ///   - intervalDays: New interval in days
    ///   - nextReminderAt: New next reminder date
    func updateTask(_ task: Task, name: String, intervalDays: Int32, nextReminderAt: Date) throws {
        task.name = name
        task.intervalDays = intervalDays
        task.nextReminderAt = nextReminderAt
        task.updatedAt = Date()
        try viewContext.save()
    }

    // MARK: - Delete

    /// Deletes a task permanently.
    func deleteTask(_ task: Task) throws {
        viewContext.delete(task)
        try viewContext.save()
    }

    // MARK: - Complete

    /// Marks a task as completed and schedules the next reminder.
    func completeTask(_ task: Task) throws {
        let now = Date()
        task.lastCompletedAt = now
        task.nextReminderAt = calculateNextReminderDate(from: now, intervalDays: task.intervalDays)
        task.updatedAt = now
        try viewContext.save()
    }

    // MARK: - Interval Calculation

    private func calculateNextReminderDate(from date: Date, intervalDays: Int32) -> Date {
        Calendar.current.date(byAdding: .day, value: Int(intervalDays), to: date) ?? date
    }
}

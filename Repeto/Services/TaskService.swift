//
//  TaskService.swift
//  Repeto
//
//  Created by Claude on 2025/12/07.
//

import CoreData
import Foundation

/// Grouped tasks by their reminder status
struct GroupedTasks {
    let overdue: [Task]
    let today: [Task]
    let upcoming: [Task]
}

/// Service for managing Task entities with CRUD operations and interval calculations
final class TaskService {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    // MARK: - Create

    /// Creates a new task with the specified parameters
    /// - Parameters:
    ///   - name: The name of the task
    ///   - intervalDays: The interval in days between reminders
    ///   - nextReminderAt: Optional next reminder date. If nil, calculates from current date + interval
    /// - Returns: The created Task object
    /// - Throws: Core Data save error
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

    // MARK: - Read

    /// Fetches all active (non-archived) tasks sorted by next reminder date
    /// - Returns: Array of active tasks
    /// - Throws: Core Data fetch error
    func fetchAllTasks() throws -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == NO")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Task.nextReminderAt, ascending: true)
        ]
        return try viewContext.fetch(request)
    }

    /// Fetches tasks grouped by status (overdue, today, upcoming)
    /// - Returns: GroupedTasks containing arrays for each category
    /// - Throws: Core Data fetch error
    func fetchTasksGrouped() throws -> GroupedTasks {
        let allTasks = try fetchAllTasks()
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return GroupedTasks(overdue: [], today: [], upcoming: allTasks)
        }

        var overdue: [Task] = []
        var today: [Task] = []
        var upcoming: [Task] = []

        for task in allTasks {
            guard let reminderDate = task.nextReminderAt else {
                upcoming.append(task)
                continue
            }

            if reminderDate < startOfToday {
                overdue.append(task)
            } else if reminderDate < startOfTomorrow {
                today.append(task)
            } else {
                upcoming.append(task)
            }
        }

        return GroupedTasks(overdue: overdue, today: today, upcoming: upcoming)
    }

    /// Fetches a task by its ID
    /// - Parameter id: The UUID of the task
    /// - Returns: The task if found, nil otherwise
    /// - Throws: Core Data fetch error
    func fetchTask(by id: UUID) throws -> Task? {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try viewContext.fetch(request).first
    }

    // MARK: - Update

    /// Updates an existing task
    /// - Parameter task: The task to update (must already have changes applied)
    /// - Throws: Core Data save error
    func updateTask(_ task: Task) throws {
        task.updatedAt = Date()
        try viewContext.save()
    }

    /// Updates a task's name and interval
    /// - Parameters:
    ///   - task: The task to update
    ///   - name: New name for the task
    ///   - intervalDays: New interval in days
    /// - Throws: Core Data save error
    func updateTask(_ task: Task, name: String, intervalDays: Int32) throws {
        task.name = name
        task.intervalDays = intervalDays
        task.updatedAt = Date()
        try viewContext.save()
    }

    // MARK: - Delete

    /// Deletes a task permanently
    /// - Parameter task: The task to delete
    /// - Throws: Core Data save error
    func deleteTask(_ task: Task) throws {
        viewContext.delete(task)
        try viewContext.save()
    }

    // MARK: - Complete

    /// Marks a task as completed and calculates the next reminder date
    /// - Parameter task: The task to complete
    /// - Throws: Core Data save error
    func completeTask(_ task: Task) throws {
        let now = Date()
        task.lastCompletedAt = now
        task.nextReminderAt = calculateNextReminderDate(
            from: now,
            intervalDays: task.intervalDays
        )
        task.updatedAt = now
        try viewContext.save()
    }

    // MARK: - Archive

    /// Archives a task (soft delete)
    /// - Parameter task: The task to archive
    /// - Throws: Core Data save error
    func archiveTask(_ task: Task) throws {
        task.isArchived = true
        task.updatedAt = Date()
        try viewContext.save()
    }

    /// Unarchives a task
    /// - Parameter task: The task to unarchive
    /// - Throws: Core Data save error
    func unarchiveTask(_ task: Task) throws {
        task.isArchived = false
        task.updatedAt = Date()
        try viewContext.save()
    }

    // MARK: - Interval Calculation

    /// Calculates the next reminder date based on the current date and interval
    /// - Parameters:
    ///   - from: The starting date for calculation
    ///   - intervalDays: The interval in days
    /// - Returns: The calculated next reminder date
    func calculateNextReminderDate(from date: Date, intervalDays: Int32) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: Int(intervalDays), to: date) ?? date
    }

    // MARK: - Statistics

    /// Returns the count of active tasks
    /// - Returns: Number of active tasks
    /// - Throws: Core Data fetch error
    func activeTaskCount() throws -> Int {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == NO")
        return try viewContext.count(for: request)
    }

    /// Returns the count of overdue tasks
    /// - Returns: Number of overdue tasks
    /// - Throws: Core Data fetch error
    func overdueTaskCount() throws -> Int {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let startOfToday = Calendar.current.startOfDay(for: Date())
        request.predicate = NSPredicate(
            format: "isArchived == NO AND nextReminderAt < %@",
            startOfToday as NSDate
        )
        return try viewContext.count(for: request)
    }
}

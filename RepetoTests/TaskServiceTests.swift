//
//  TaskServiceTests.swift
//  RepetoTests
//
//  Created by Claude on 2025/12/07.
//

import XCTest
import CoreData
@testable import Repeto

final class TaskServiceTests: XCTestCase {
    var taskService: TaskService?
    var container: NSPersistentContainer?

    override func setUpWithError() throws {
        // Load the managed object model from the main bundle
        guard let modelURL = Bundle(for: TaskService.self).url(
            forResource: "Repeto",
            withExtension: "momd"
        ) else {
            XCTFail("Failed to find Core Data model")
            return
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            XCTFail("Failed to load Core Data model")
            return
        }

        let container = NSPersistentContainer(name: "Repeto", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }

        if let error = loadError {
            throw error
        }

        self.container = container
        self.taskService = TaskService(context: container.viewContext)
    }

    override func tearDownWithError() throws {
        // Clean up the persistent store
        // Note: taskService and container will be naturally deallocated
        // after the test instance is released
        if let container = container {
            for store in container.persistentStoreCoordinator.persistentStores {
                try? container.persistentStoreCoordinator.remove(store)
            }
        }
    }

    // MARK: - Create Tests

    func testCreateTask() throws {
        let sut = try XCTUnwrap(taskService)
        let task = try sut.createTask(
            name: "Test Task",
            intervalDays: 7
        )

        XCTAssertNotNil(task.id)
        XCTAssertEqual(task.name, "Test Task")
        XCTAssertEqual(task.intervalDays, 7)
        XCTAssertFalse(task.isArchived)
        XCTAssertNotNil(task.createdAt)
        XCTAssertNotNil(task.nextReminderAt)
    }

    func testCreateTaskWithCustomReminderDate() throws {
        let sut = try XCTUnwrap(taskService)
        let customDate = Date().addingTimeInterval(86400 * 3)
        let task = try sut.createTask(
            name: "Custom Date Task",
            intervalDays: 7,
            nextReminderAt: customDate
        )

        XCTAssertEqual(
            task.nextReminderAt?.timeIntervalSinceReferenceDate ?? 0,
            customDate.timeIntervalSinceReferenceDate,
            accuracy: 1.0
        )
    }

    // MARK: - Read Tests

    func testFetchAllTasks() throws {
        let sut = try XCTUnwrap(taskService)
        try sut.createTask(name: "Task 1", intervalDays: 7)
        try sut.createTask(name: "Task 2", intervalDays: 14)

        let tasks = try sut.fetchAllTasks()

        XCTAssertEqual(tasks.count, 2)
    }

    func testFetchAllTasksExcludesArchived() throws {
        let sut = try XCTUnwrap(taskService)
        let task1 = try sut.createTask(name: "Active", intervalDays: 7)
        let task2 = try sut.createTask(name: "Archived", intervalDays: 7)
        try sut.archiveTask(task2)

        let tasks = try sut.fetchAllTasks()

        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.id, task1.id)
    }

    func testFetchTaskById() throws {
        let sut = try XCTUnwrap(taskService)
        let created = try sut.createTask(name: "Find Me", intervalDays: 7)

        let found = try sut.fetchTask(by: created.id!)

        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "Find Me")
    }

    func testFetchTaskByIdNotFound() throws {
        let sut = try XCTUnwrap(taskService)
        let found = try sut.fetchTask(by: UUID())

        XCTAssertNil(found)
    }

    func testFetchTasksGrouped() throws {
        let sut = try XCTUnwrap(taskService)
        let calendar = Calendar.current

        // Overdue task (yesterday)
        let overdueTask = try sut.createTask(
            name: "Overdue",
            intervalDays: 7,
            nextReminderAt: calendar.date(byAdding: .day, value: -1, to: Date())
        )

        // Today's task
        let todayTask = try sut.createTask(
            name: "Today",
            intervalDays: 7,
            nextReminderAt: Date()
        )

        // Upcoming task (tomorrow)
        let upcomingTask = try sut.createTask(
            name: "Upcoming",
            intervalDays: 7,
            nextReminderAt: calendar.date(byAdding: .day, value: 1, to: Date())
        )

        let grouped = try sut.fetchTasksGrouped()

        XCTAssertEqual(grouped.overdue.count, 1)
        XCTAssertEqual(grouped.overdue.first?.id, overdueTask.id)

        XCTAssertEqual(grouped.today.count, 1)
        XCTAssertEqual(grouped.today.first?.id, todayTask.id)

        XCTAssertEqual(grouped.upcoming.count, 1)
        XCTAssertEqual(grouped.upcoming.first?.id, upcomingTask.id)
    }

    // MARK: - Update Tests

    func testUpdateTask() throws {
        let sut = try XCTUnwrap(taskService)
        let task = try sut.createTask(name: "Original", intervalDays: 7)
        let originalUpdatedAt = task.updatedAt

        // Wait a moment to ensure different timestamp
        try sut.updateTask(task, name: "Updated", intervalDays: 14)

        XCTAssertEqual(task.name, "Updated")
        XCTAssertEqual(task.intervalDays, 14)
        XCTAssertNotEqual(task.updatedAt, originalUpdatedAt)
    }

    // MARK: - Delete Tests

    func testDeleteTask() throws {
        let sut = try XCTUnwrap(taskService)
        let task = try sut.createTask(name: "Delete Me", intervalDays: 7)
        let taskId = task.id!

        try sut.deleteTask(task)

        let found = try sut.fetchTask(by: taskId)
        XCTAssertNil(found)
    }

    // MARK: - Complete Tests

    func testCompleteTask() throws {
        let sut = try XCTUnwrap(taskService)
        let task = try sut.createTask(name: "Complete Me", intervalDays: 7)

        XCTAssertNil(task.lastCompletedAt)

        try sut.completeTask(task)

        XCTAssertNotNil(task.lastCompletedAt)
        XCTAssertNotNil(task.nextReminderAt)
    }

    func testCompleteTaskUpdatesNextReminder() throws {
        let sut = try XCTUnwrap(taskService)
        let task = try sut.createTask(
            name: "Complete Me",
            intervalDays: 7,
            nextReminderAt: Date()
        )

        let beforeComplete = Date()
        try sut.completeTask(task)

        let expectedNextReminder = Calendar.current.date(
            byAdding: .day,
            value: 7,
            to: beforeComplete
        )!

        XCTAssertEqual(
            task.nextReminderAt?.timeIntervalSinceReferenceDate ?? 0,
            expectedNextReminder.timeIntervalSinceReferenceDate,
            accuracy: 2.0
        )
    }

    // MARK: - Interval Calculation Tests

    func testCalculateNextReminderDate() throws {
        let sut = try XCTUnwrap(taskService)
        let startDate = Date()

        let nextDate = sut.calculateNextReminderDate(
            from: startDate,
            intervalDays: 7
        )

        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents(
            [.day],
            from: startDate,
            to: nextDate
        ).day

        XCTAssertEqual(daysDiff, 7)
    }

    func testCalculateNextReminderDateWithDifferentIntervals() throws {
        let sut = try XCTUnwrap(taskService)
        let startDate = Date()
        let calendar = Calendar.current

        // Test 1 day interval
        let oneDay = sut.calculateNextReminderDate(from: startDate, intervalDays: 1)
        XCTAssertEqual(
            calendar.dateComponents([.day], from: startDate, to: oneDay).day,
            1
        )

        // Test 30 day interval
        let thirtyDays = sut.calculateNextReminderDate(from: startDate, intervalDays: 30)
        XCTAssertEqual(
            calendar.dateComponents([.day], from: startDate, to: thirtyDays).day,
            30
        )
    }

    // MARK: - Archive Tests

    func testArchiveTask() throws {
        let sut = try XCTUnwrap(taskService)
        let task = try sut.createTask(name: "Archive Me", intervalDays: 7)

        XCTAssertFalse(task.isArchived)

        try sut.archiveTask(task)

        XCTAssertTrue(task.isArchived)
    }

    func testUnarchiveTask() throws {
        let sut = try XCTUnwrap(taskService)
        let task = try sut.createTask(name: "Unarchive Me", intervalDays: 7)
        try sut.archiveTask(task)

        XCTAssertTrue(task.isArchived)

        try sut.unarchiveTask(task)

        XCTAssertFalse(task.isArchived)
    }

    // MARK: - Statistics Tests

    func testActiveTaskCount() throws {
        let sut = try XCTUnwrap(taskService)
        try sut.createTask(name: "Active 1", intervalDays: 7)
        try sut.createTask(name: "Active 2", intervalDays: 7)
        let archivedTask = try sut.createTask(name: "Archived", intervalDays: 7)
        try sut.archiveTask(archivedTask)

        let count = try sut.activeTaskCount()

        XCTAssertEqual(count, 2)
    }

    func testOverdueTaskCount() throws {
        let sut = try XCTUnwrap(taskService)
        let calendar = Calendar.current

        // Overdue tasks
        try sut.createTask(
            name: "Overdue 1",
            intervalDays: 7,
            nextReminderAt: calendar.date(byAdding: .day, value: -2, to: Date())
        )
        try sut.createTask(
            name: "Overdue 2",
            intervalDays: 7,
            nextReminderAt: calendar.date(byAdding: .day, value: -1, to: Date())
        )

        // Not overdue
        try sut.createTask(
            name: "Future",
            intervalDays: 7,
            nextReminderAt: calendar.date(byAdding: .day, value: 1, to: Date())
        )

        let count = try sut.overdueTaskCount()

        XCTAssertEqual(count, 2)
    }
}

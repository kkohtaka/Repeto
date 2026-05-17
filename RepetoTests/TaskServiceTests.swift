//
//  TaskServiceTests.swift
//  RepetoTests
//
//  Created by Claude on 2025/12/07.
//

import XCTest
import CoreData
@testable import Repeto

@MainActor
final class TaskServiceTests: XCTestCase {
    var taskService: TaskService?
    var container: NSPersistentContainer?

    override func setUpWithError() throws {
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
        if let container = container {
            for store in container.persistentStoreCoordinator.persistentStores {
                try? container.persistentStoreCoordinator.remove(store)
            }
        }
    }

    // MARK: - Create Tests

    func testCreateTask() throws {
        let sut = try XCTUnwrap(taskService)
        let task = try sut.createTask(name: "Test Task", intervalDays: 7)

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

    func testCreateTaskDefaultsNextReminderToInterval() throws {
        let sut = try XCTUnwrap(taskService)
        let before = Date()
        let task = try sut.createTask(name: "Interval Task", intervalDays: 7)
        let after = Date()

        let expectedMin = Calendar.current.date(byAdding: .day, value: 7, to: before)!
        let expectedMax = Calendar.current.date(byAdding: .day, value: 7, to: after)!
        let actual = try XCTUnwrap(task.nextReminderAt)

        XCTAssertGreaterThanOrEqual(actual, expectedMin)
        XCTAssertLessThanOrEqual(actual, expectedMax)
    }

    // MARK: - Update Tests

    func testUpdateTask() throws {
        let sut = try XCTUnwrap(taskService)
        let task = try sut.createTask(name: "Original", intervalDays: 7)
        let originalUpdatedAt = task.updatedAt
        let newDate = Date().addingTimeInterval(86400 * 14)

        try sut.updateTask(task, name: "Updated", intervalDays: 14, nextReminderAt: newDate)

        XCTAssertEqual(task.name, "Updated")
        XCTAssertEqual(task.intervalDays, 14)
        XCTAssertNotEqual(task.updatedAt, originalUpdatedAt)
        XCTAssertEqual(
            task.nextReminderAt?.timeIntervalSinceReferenceDate ?? 0,
            newDate.timeIntervalSinceReferenceDate,
            accuracy: 1.0
        )
    }

    // MARK: - Delete Tests

    func testDeleteTask() throws {
        let sut = try XCTUnwrap(taskService)
        let container = try XCTUnwrap(self.container)
        let task = try sut.createTask(name: "Delete Me", intervalDays: 7)
        let taskId = try XCTUnwrap(task.id)

        try sut.deleteTask(task)

        let request = NSFetchRequest<Task>(entityName: "Task")
        request.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)
        let results = try container.viewContext.fetch(request)
        XCTAssertTrue(results.isEmpty)
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

    func testCompleteTaskWithDifferentIntervals() throws {
        let sut = try XCTUnwrap(taskService)
        let calendar = Calendar.current

        let task30 = try sut.createTask(name: "30 Days", intervalDays: 30)
        let before30 = Date()
        try sut.completeTask(task30)
        let expected30 = calendar.date(byAdding: .day, value: 30, to: before30)!
        XCTAssertEqual(
            task30.nextReminderAt?.timeIntervalSinceReferenceDate ?? 0,
            expected30.timeIntervalSinceReferenceDate,
            accuracy: 2.0
        )

        let task1 = try sut.createTask(name: "1 Day", intervalDays: 1)
        let before1 = Date()
        try sut.completeTask(task1)
        let expected1 = calendar.date(byAdding: .day, value: 1, to: before1)!
        XCTAssertEqual(
            task1.nextReminderAt?.timeIntervalSinceReferenceDate ?? 0,
            expected1.timeIntervalSinceReferenceDate,
            accuracy: 2.0
        )
    }
}

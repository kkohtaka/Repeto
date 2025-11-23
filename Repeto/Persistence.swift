//
//  Persistence.swift
//  Repeto
//
//  Created by Kazumasa Kohtaka on 2025/11/01.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // プレビュー用のサンプルデータを追加
        for i in 0..<5 {
            let newTask = Task(context: viewContext)
            newTask.id = UUID()
            newTask.name = "Sample Task \(i + 1)"
            newTask.intervalDays = Int32((i + 1) * 7)
            newTask.createdAt = Date()
            newTask.updatedAt = Date()
            newTask.isArchived = false

            if i < 2 {
                // 最初の2つは完了済みとして設定
                newTask.lastCompletedAt = Date().addingTimeInterval(-Double(i + 1) * 86400)
                newTask.nextReminderAt = Date().addingTimeInterval(Double((i + 1) * 7) * 86400)
            }
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return controller
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Repeto")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

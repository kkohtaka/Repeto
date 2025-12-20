//
//  RepetoApp.swift
//  Repeto
//
//  Created by Kazumasa Kohtaka on 2025/11/01.
//

import SwiftUI
import CoreData

@main
struct RepetoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

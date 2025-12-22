//
//  TaskRowView.swift
//  Repeto
//
//  Created by Claude on 2025/12/20.
//

import CoreData
import SwiftUI

struct TaskRowView: View {
    let task: Task

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Task name
            Text(task.displayName)
                .font(.body)
                .foregroundColor(.primary)

            // Next reminder date with status color
            HStack(spacing: 4) {
                Image(systemName: "bell.fill")
                    .font(.caption2)
                    .foregroundColor(statusColor)

                Text(task.safeNextReminderAt.relativeDateString)
                    .font(.subheadline)
                    .foregroundColor(statusColor)
            }

            // Interval information
            Text(task.intervalText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    /// Color based on task status
    private var statusColor: Color {
        switch task.status {
        case .overdue:
            return .red
        case .today:
            return .orange
        case .upcoming:
            return .primary
        case .unknown:
            return .secondary
        }
    }
}

#Preview("Overdue Task") {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context)
    task.id = UUID()
    task.name = "部屋の掃除"
    task.intervalDays = 7
    task.nextReminderAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())
    task.createdAt = Date()

    return List {
        TaskRowView(task: task)
    }
}

#Preview("Today Task") {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context)
    task.id = UUID()
    task.name = "食材の買い出し"
    task.intervalDays = 3
    task.nextReminderAt = Date()
    task.createdAt = Date()

    return List {
        TaskRowView(task: task)
    }
}

#Preview("Upcoming Task") {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context)
    task.id = UUID()
    task.name = "ゴミ出し"
    task.intervalDays = 1
    task.nextReminderAt = Calendar.current.date(byAdding: .day, value: 2, to: Date())
    task.createdAt = Date()

    return List {
        TaskRowView(task: task)
    }
}

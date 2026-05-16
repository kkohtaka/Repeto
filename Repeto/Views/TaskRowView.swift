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
        VStack(alignment: .leading, spacing: DesignSystem.spacing(.xs)) {
            Text(task.displayName)
                .font(.body)
                .foregroundStyle(.primary)

            HStack(spacing: DesignSystem.spacing(.xs)) {
                Image(systemName: "bell.fill")
                    .font(.caption2)
                    .foregroundStyle(statusColor)

                Text(task.safeNextReminderAt.relativeDateString)
                    .font(.subheadline)
                    .foregroundStyle(statusColor)
            }

            Text(task.intervalText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, DesignSystem.spacing(.xs))
    }

    private var statusColor: Color {
        switch task.status {
        case .overdue:  DesignSystem.statusColor(.overdue)
        case .today:    DesignSystem.statusColor(.today)
        case .upcoming: DesignSystem.statusColor(.upcoming)
        case .unknown:  .secondary
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
    return List { TaskRowView(task: task) }
}

#Preview("Today Task") {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context)
    task.id = UUID()
    task.name = "食材の買い出し"
    task.intervalDays = 3
    task.nextReminderAt = Date()
    task.createdAt = Date()
    return List { TaskRowView(task: task) }
}

#Preview("Upcoming Task") {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context)
    task.id = UUID()
    task.name = "ゴミ出し"
    task.intervalDays = 1
    task.nextReminderAt = Calendar.current.date(byAdding: .day, value: 2, to: Date())
    task.createdAt = Date()
    return List { TaskRowView(task: task) }
}

//
//  Task+Extension.swift
//  Repeto
//
//  Created by Claude on 2025/12/20.
//

import Foundation
import CoreData

extension Task {
    /// Task status based on next reminder date
    enum Status {
        case overdue
        case today
        case upcoming
        case unknown
    }

    /// Returns the status of this task based on next reminder date
    var status: Status {
        guard let reminderDate = nextReminderAt else {
            return .unknown
        }

        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return .unknown
        }

        if reminderDate < startOfToday {
            return .overdue
        } else if reminderDate < startOfTomorrow {
            return .today
        } else {
            return .upcoming
        }
    }

    /// Returns true if the task is overdue
    var isOverdue: Bool {
        status == .overdue
    }

    /// Returns true if the task is due today
    var isToday: Bool {
        status == .today
    }

    /// Returns true if the task is upcoming (future)
    var isUpcoming: Bool {
        status == .upcoming
    }

    /// Returns a formatted string for the interval (e.g., "7日ごと")
    var intervalText: String {
        if intervalDays == 1 {
            return "毎日"
        } else {
            return "\(intervalDays)日ごと"
        }
    }

    /// Returns the display name, fallback to "無題" if empty
    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        }
        return "無題"
    }

    /// Returns a safe unwrapped next reminder date, or current date if nil
    var safeNextReminderAt: Date {
        nextReminderAt ?? Date()
    }
}

//
//  Date+Extension.swift
//  Repeto
//
//  Created by Claude on 2025/12/20.
//

import Foundation

extension Date {
    /// Formats date as "M月d日 (E)" (e.g., "12月20日 (金)")
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日 (E)"
        return formatter.string(from: self)
    }

    /// Formats date as "M月d日" (e.g., "12月20日")
    var shortDateWithoutWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: self)
    }

    /// Formats date as "yyyy年M月d日" (e.g., "2025年12月20日")
    var longDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: self)
    }

    /// Formats date as "HH:mm" (e.g., "14:30")
    var timeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    /// Returns relative date string (e.g., "今日", "明日", "昨日")
    var relativeDateString: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(self) {
            return "今日"
        } else if calendar.isDateInYesterday(self) {
            return "昨日"
        } else if calendar.isDateInTomorrow(self) {
            return "明日"
        }

        return shortDateString
    }
}

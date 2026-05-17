//
//  Date+Extension.swift
//  Repeto
//
//  Created by Claude on 2025/12/20.
//

import Foundation

extension Date {
    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日 (E)"
        return formatter
    }()

    /// Formats date as "M月d日 (E)" (e.g., "12月20日 (金)")
    var shortDateString: String {
        Date.shortDateFormatter.string(from: self)
    }

    /// Returns a relative date string (e.g., "今日", "明日", "昨日"), falling back to shortDateString
    var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) { return "今日" }
        if calendar.isDateInYesterday(self) { return "昨日" }
        if calendar.isDateInTomorrow(self) { return "明日" }
        return shortDateString
    }
}

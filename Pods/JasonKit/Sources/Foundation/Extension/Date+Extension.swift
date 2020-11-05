//
//  DateExtension.swift
//  AppCore
//
//  Created by Hang Yu on 2018/7/3.
//  Copyright © 2018 若友网络科技有限公司. All rights reserved.
//

import Foundation

public extension Date {
    struct DateFormatType {
        let dateInCurrentDayFormat: String
        let dateInCurrentYearFormat: String
        let detailedDateFormat: String

        public init(dateInCurrentDayFormat: String, dateInCurrentYearFormat: String, detailedDateFormat: String) {
            self.dateInCurrentDayFormat = dateInCurrentDayFormat
            self.dateInCurrentYearFormat = dateInCurrentYearFormat
            self.detailedDateFormat = detailedDateFormat
        }
    }

    private static let dateFormatter: DateFormatter = DateFormatter()

    /// Get a Chinese "xx ago" string
    var dateStringWithAgo: String {
        let calendar = Calendar.current
        let now = Date()

        let diff = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: now)
        let yearsDiff = diff.year ?? 0
        let monthsDiff = diff.month ?? 0
        let daysDiff = diff.day ?? 0
        let hoursDiff = diff.hour ?? 0
        let minutesDiff = diff.minute ?? 0

        // 1. year > 0
        if yearsDiff >= 1 {
            return "\(yearsDiff)年前"
        }
        // 2. month > 0
        else if monthsDiff >= 1 {
            return "\(monthsDiff)个月前"
        }
        // 3. if daysDiff >= 1, aka >= 24 hours
        else if daysDiff >= 1 {
            return "\(daysDiff)天前"
        }
        // 4. if within 24 hours, and hoursDiff >= 1
        else if hoursDiff >= 1 {
            return "\(hoursDiff)小时前"
        }
        // 5. if within 1 hour, but minutes diff >= 1
        else if minutesDiff >= 1 {
            return "\(minutesDiff)分钟前"
        }
        // 6. otherwise
        else {
            return "刚刚"
        }
    }

    func generateDateString(of dateFormatType: DateFormatType) -> String {
        let formatter = Date.dateFormatter
        let calendar = Calendar.current
        if calendar.isDateInToday(self) == true {
            formatter.dateFormat = dateFormatType.dateInCurrentDayFormat
        } else {
            let currentYear = calendar.component(.year, from: Date())
            let createdYear = calendar.component(.year, from: self)
            if currentYear == createdYear {
                formatter.dateFormat = dateFormatType.dateInCurrentYearFormat
            } else {
                formatter.dateFormat = dateFormatType.detailedDateFormat
            }
        }
        return formatter.string(from: self)
    }

    /// Past days in number
    var daysAgo: Int {
        let calendar = Calendar.current

        let absoluteSecondsDiff = Int(Date().timeIntervalSince1970 - self.timeIntervalSince1970)

        let now = Date()
        let hourOfNow = calendar.component(.hour, from: now)
        let minuteOfNow = calendar.component(.minute, from: now)
        let secondsOfNow = calendar.component(.second, from: now)
        let totalSecondsOfToday = (hourOfNow * 60 + minuteOfNow) * 60 + secondsOfNow

        if absoluteSecondsDiff - totalSecondsOfToday <= 0 {
            return 0
        }

        let secondsBeforeToday = Double(absoluteSecondsDiff - totalSecondsOfToday)

        // if there's one minute before today, make it a day
        let days = ceil(secondsBeforeToday / 60 / 60 / 24)
        return Int(days)
    }

    /// Get a Date instance by providing year/month/day
    static func getDate(year: Int, month: Int, day: Int) -> Date? {
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.timeZone = TimeZone.current

        // Create date from components
        let userCalendar = Calendar.current // user calendar
        return userCalendar.date(from: dateComponents)
    }

    /// Get timestamp in milliseconds (javascript prefered way)
    var millisecondsSince1970: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

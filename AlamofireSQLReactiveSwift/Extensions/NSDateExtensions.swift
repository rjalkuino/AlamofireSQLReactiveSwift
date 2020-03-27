//
//  NSDateExtensions.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//


import Foundation

private let rfc3339DateFormatter1: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
    dateFormatter.timeZone = .current
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
    return dateFormatter
    }()

private let rfc3339DateFormatter2: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
    dateFormatter.timeZone = .current
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    return dateFormatter
    }()

public extension Date {
    
    static func fromRFC3339String(str: String) -> Date? {
        if let date = rfc3339DateFormatter1.date(from: str) {
            return date
        } else if let date = rfc3339DateFormatter2.date(from: str) {
            return date
        }
        return nil
    }
    
    func toRFC3339String() -> String {
        return rfc3339DateFormatter1.string(from: self)
    }
    
}

extension Date {

    private enum RoundedDuration: String {
        case Seconds = "seconds"
        case Minutes = "minutes"
        case Hours = "hours"
        case Days = "days"
        case Weeks = "weeks"
    }
    
    private func calc() -> (Int, RoundedDuration) {
        let oneMinuteMark: TimeInterval = 60
        let oneHourMark: TimeInterval = oneMinuteMark * 60
        let oneDayMark: TimeInterval = oneHourMark * 24
        let oneWeekMark: TimeInterval = oneDayMark * 7
        let differenceInSeconds = -self.timeIntervalSinceNow
    
        if differenceInSeconds < 0 {
            return(0, .Seconds)
        }
    
        switch differenceInSeconds {
        case 0...oneMinuteMark:
            return(Int(differenceInSeconds), .Seconds)
        case oneMinuteMark...oneHourMark:
            return(Int(differenceInSeconds / oneMinuteMark), .Minutes)
        case oneHourMark...oneDayMark:
            return(Int(differenceInSeconds / oneHourMark), .Hours)
        case oneDayMark...oneWeekMark:
            return(Int(differenceInSeconds / oneDayMark), .Days)
        default:
            return(Int(differenceInSeconds / oneWeekMark), .Weeks)
        }
    }
    
    var shortDescription: String {
        let (value, type) = calc()
        return "\(value)\(Array(type.rawValue)[0])"
    }
    
//    var longDescription: String {
//        let (value, type) = calc()
//        let typeRaw = type.rawValue
//        let typeString = value == 1 ? typeRaw..substringToIndex(typeRaw.endIndex.advancedBy(-1)) : typeRaw
//        return "\(value) \(typeString) ago"
//    }
}

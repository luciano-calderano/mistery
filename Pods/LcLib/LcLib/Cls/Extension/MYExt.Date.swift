//
//  ExtDate.swift
//  Lc
//
//  Created by Luciano Calderano on 2018
//  Copyright © 2018 Lc. All rights reserved.
//

import Foundation

public extension String {
    func toDate(withFormat fmt: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = fmt
        if let result = df.date(from: self) {
            return result
        }
        return nil
    }

    func dateConvert(fromFormat fmtIn: String, toFormat fmtOut: String) -> String {
        if let d = self.toDate(withFormat: fmtIn) {
            return d.toString(withFormat: fmtOut)
        }
        return ""
    }

    func toUtcDate(inputFormat: String, outputFormat: String? = nil) -> String {
        let df = DateFormatter()
        df.dateFormat = inputFormat
        df.calendar = NSCalendar.current
        df.timeZone = TimeZone.current

        guard let d = df.date(from: self) else {
            return ""
        }
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = outputFormat ?? inputFormat
        let outString = df.string(from: d)
        return outString
    }
    
    func fromUtcDate(inputFormat: String, outputFormat: String? = nil) -> String {
        let df = DateFormatter()
        df.dateFormat = inputFormat
        df.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let d = df.date(from: self) else {
            return ""
        }
        df.timeZone = TimeZone.current
        df.calendar = NSCalendar.current
        df.dateFormat = outputFormat ?? inputFormat
        let outString = df.string(from: d)
        return outString
    }

}

public extension Date {
    func toString(withFormat fmt: String) -> String {
        let df = DateFormatter()
        df.dateFormat = fmt
        return df.string(from: self)
    }
}

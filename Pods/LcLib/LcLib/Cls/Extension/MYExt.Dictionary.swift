//
//  ExtDictionary.swift
//  Lc
//
//  Created by Luciano Calderano on 2018
//  Copyright © 2018 Lc. All rights reserved.
//

import Foundation
public var jsonSeparator = "->"
public extension Dictionary {
    private func value (_ keys: String) -> Any? {
        let array = keys.components(separatedBy: jsonSeparator)
        
        var dic = self as! Dictionary<String, Any>
        for key in array.dropLast() {
            guard let next = dic[key] as? Dictionary<String, Any> else {
                return nil
            }
            dic = next
        }
        
        if let k = array.last, let value = dic[k] {
            return value
        }
        return nil
    }
    
    func double (_ key: String) -> Double {
        if let v = value(key) {
            if v is Double {
                return v as! Double
            }
            if let s = v as? String, s.count > 0 {
                return Double(s)!
            }
        }
        return 0
    }
    
    func int (_ key: String) -> Int {
        if let v = value(key) {
            if v is Int {
                return v as! Int
            }
            if let s = v as? String, s.count > 0 {
                return Int(s)!
            }
        }
        return 0
    }
    
    func bool (_ key: String) -> Bool {
        if let v = value(key) {
            if v is Bool {
                return v as! Bool
            }
            if let s = v as? String, s.count > 0 {
                return s == "1" || s.lowercased() == "true" || s.lowercased().left(lenght: 1) == "y"
            }
        }
        return false
    }
    
    func date (_ key: String, fmt: String = "") -> Date? {
        if let v = value(key) {
            if v is Date {
                return v as? Date
            }
            if fmt.count > 0, let s = v as? String, s.count > 0 {
                return s.toDate(withFormat: fmt)
            }
        }
        return nil
    }
    
    func string (_ key: String) -> String {
        if let s = value(key) as? String {
            return s
        }
        return ""
    }
    
    func dictionary(_ key: String) -> Dictionary<Key, Value> {
        if let dict = value(key) as? Dictionary<Key, Value> {
            return dict
        }
        return [:]
    }
    
    func array(_ key: String) -> Array<Any> {
        if let arr = value(key) as? Array<Any> {
            return arr
        }
        return []
    }
}

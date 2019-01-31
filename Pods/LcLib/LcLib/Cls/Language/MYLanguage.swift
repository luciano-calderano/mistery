//
//  MYLang.swift
//  Lc
//
//  Created by Luciano Calderano on 2018
//  Copyright © 2018 Lc. All rights reserved.
//

import Foundation

private typealias LangDict = [String: String]

public extension String {
    func toLang() -> String {
        if self.isEmpty {
            return ""
        }
        return left(lenght: 1) == "#" ? MYLang.value(mid(startAtChar: 2)) : self
    }
}

public class MYLang {
    public static func value (_ key: String) -> String {
        return MYLang.shared.getValue (key: key)
    }
    public static func setup (langListCodes l: [String], langFileName f: String) {
        MYLang.shared.setup(langListCodes: l, langFileName: f)
    }

    public static let shared = MYLang()
    
    public func setLanguage(code: String) {
        var selectedLangIdx = 0
        if let idx = langList.index(of: code) {
            selectedLangIdx = idx
        }
        dict = loadLanguage(index: selectedLangIdx)
    }
    
    func getValue(key: String) -> String {
        if let value = dict[key] {
            let newLine = "\\n"
            if value.range(of: newLine) != nil {
                return value.replacingOccurrences(of: newLine, with: "\n")
            }
            return value
        }
        return "[Key:" + key + "?]"
    }

    //MARK:- private
    
    private var langList = [""]
    private var fileName =  ""
    private var dict = LangDict()

    private func setup (langListCodes l: [String], langFileName f: String) {
        langList = l
        fileName = f

        let lng = selectLanguageFromDevice()
        setLanguage(code: lng)
    }

    private func selectLanguageFromDevice() -> String {
        var strIso = Locale.current.identifier
        if (strIso.count < 2) {
            strIso = Bundle.main.preferredLocalizations.first!
        }
        else if (strIso.count > 2) {
            strIso = strIso.left(lenght: 2)
        }
        return strIso
    }
    
    private func loadLanguage(index: Int) -> LangDict {
        let arr = fileName.components(separatedBy: ".")
        if arr.count != 2 {
            return [:]
        }
        let filePath = Bundle.main.path(forResource: arr.first, ofType: arr.last)
        
        let str = try? String(contentsOfFile: filePath!, encoding: String.Encoding.utf8) as String
        let array = (str?.components(separatedBy: "\n"))! as [String]
        var dic = [String: String]()
        
        for s in array {
            let riga = s.components(separatedBy: "=")
            guard riga.count == 2 else {
                continue
            }
            let valuesArray = riga.last!.components(separatedBy: "|") as [String]
            guard valuesArray.count == langList.count else {
                continue
            }
            dic[riga.first!] = valuesArray[index]
        }
        return dic
    }
}


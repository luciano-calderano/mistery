//
//  ExtString.swift
//  Lc
//
//  Created by Luciano Calderano on 2018
//  Copyright © 2018 Lc. All rights reserved.
//

import Foundation

public extension String {
    func left (lenght l: Int) -> String {
        if (l < 1) {
            return ""
        }
        let fine = l < count ? l : count
        return range(0, fine: fine)
    }

    func mid (startAtChar iniz: Int, lenght l: Int = 0) -> String {
        if iniz > count {
            return ""
        }
        let i = (iniz < 1) ? 0 : iniz - 1
        let f = (l == 0 || (i + l) > count) ? count : (i + l)
        return range(i, fine: f)
    }

    func right (l: Int) -> String {
        if (l < 1) {
            return ""
        }
        var iniz = count - l;
        if iniz < 0 {
            iniz = 0
        }
        return range(iniz, fine: count)
    }
    
    private func range (_ iniz: Int, fine: Int) -> String {
        let ini = index(startIndex, offsetBy: iniz)
        let end = index(startIndex, offsetBy: fine)
        let s = self[ini..<end]
        return String(s)
    }

}

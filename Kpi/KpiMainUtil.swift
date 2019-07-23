//
//  KpiMainUtil.swift
//  MysteryClient
//
//  Created by Lc on 12/04/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit

protocol KpiSubViewDelegate {
    func kpiViewHeight(_ height: CGFloat)
    func valuationSelected (_ valuation: Job.Kpi.Valuation)
}

protocol KpiDelegate {
    func kpiStartEditingAtPosY (_ y: CGFloat)
    func kpiEndEditing ()
}

extension KpiDelegate {
    func kpiStartEditingAtPosY (_ y: CGFloat) {}
    func kpiEndEditing () {}
}

struct KpiResponseValues {
    var value = ""
    var notesReq = false
    var attchReq = false
    var dependencies = [Job.Kpi.Valuation.Dependency]()
}

enum KpiResultType {
    case next
    case last
    
    case errValue
    case errNotes
    case errAttch
    case errComment
    case err
}

class InvalidKpi {
    private static var kpiKeyList = [Int]() // Di comodo per evitare la ricerca del kpi.id nell'array dei kpi
    class func resetKeyList () {
        kpiKeyList.removeAll()
        for kpi in Current.job.kpis {
            kpi.isValid = true
            kpiKeyList.append(kpi.id)
        }
    }
    
    class func resetDependenciesWithKpi (_ kpi: Job.Kpi) {
        for val in kpi.valuations {
            for dep in val.dependencies {
                fixValuation(isValid: true, dep: dep)
            }
        }
    }
    
    class func updateWithResponse (_ response: KpiResponseValues!) {
        for dep in response.dependencies {
            fixValuation(isValid: false, dep: dep)
        }
    }
    
    private class func fixValuation (isValid: Bool, dep: Job.Kpi.Valuation.Dependency) {
        if let idx = kpiKeyList.firstIndex(of: dep.key) {
            Current.job.kpis[idx].isValid = isValid
            
            let kpiResult = Current.result.results[idx]
            kpiResult.kpi_id = dep.key
            kpiResult.value = isValid ? "" : dep.value
            kpiResult.notes = isValid ? "" : dep.notes
            Current.result.results[idx] = kpiResult
        }
    }
}



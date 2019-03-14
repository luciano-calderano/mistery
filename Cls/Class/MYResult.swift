//
//  MYResult.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

class MYResult {
    static let shared = MYResult()
    static var resultDict = JsonDict()

    func loadCurrentResult () -> JobResult {
        var result = JobResult()
        let dict = JsonDict(fromFile: Current.resultFile)
        if dict.isEmpty {
            result.id = Current.job.id
            return result
        }

        result.id                     = dict.int("id")
//        result.estimate_date          = dict.string("estimate_date")
        result.compiled               = dict.int("compiled")
        result.compilation_date       = dict.string("compilation_date")
        result.updated                = dict.int("updated")
        result.update_date            = dict.string("update_date")
        result.execution_date         = dict.string("execution_date")
        result.execution_start_time   = dict.string("execution_start_time")
        result.execution_end_time     = dict.string("execution_end_time")
        result.store_closed           = dict.int("store_closed")
        result.comment                = dict.string("comment")
        
        let pos = dict.dictionary("positioning")
        result.positioning.start      = pos.bool("start")
        result.positioning.start_date = pos.string("start_date")
        result.positioning.start_lat  = pos.double("start_lat")
        result.positioning.start_lng  = pos.double("start_lng")
        result.positioning.end        = pos.bool("end")
        result.positioning.end_date   = pos.string("end_date")
        result.positioning.end_lat    = pos.double("end_lat")
        result.positioning.end_lng    = pos.double("end_lng")
        
        for kpiDict in dict.array("results") as! [JsonDict] {
            let kpiResult = JobResult.KpiResult()
            kpiResult.kpi_id        = kpiDict.int("kpi_id")
            kpiResult.value         = kpiDict.string("value")
            kpiResult.notes         = kpiDict.string("notes")
            kpiResult.attachment    = kpiDict.string("attachment")
            result.results.append(kpiResult)
        }
        return result
    }
    
    func saveCurrentResult () {
        var resultArray = [JsonDict]()
        let curRes = Current.result
        
        for kpiResult in curRes.results {
            let dict:JsonDict = [
                "kpi_id"     : kpiResult.kpi_id,
                "value"      : kpiResult.value,
                "notes"      : kpiResult.notes,
                "attachment" : kpiResult.attachment,
                ]
            resultArray.append(dict)
        }

        let dictPos:JsonDict = [
            "start"      : curRes.positioning.start,
            "start_date" : curRes.positioning.start_date,
            "start_lat"  : curRes.positioning.start_lat,
            "start_lng"  : curRes.positioning.start_lng,
            "end"        : curRes.positioning.end,
            "end_date"   : curRes.positioning.end_date,
            "end_lat"    : curRes.positioning.end_lat,
            "end_lng"    : curRes.positioning.end_lng,
            ]
        
         MYResult.resultDict = [
            "id"                        : curRes.id,
            "compiled"                  : curRes.compiled,
            "compilation_date"          : curRes.compilation_date,
            "updated"                   : curRes.updated,
            "update_date"               : curRes.update_date,
            "execution_date"            : curRes.execution_date,
            "execution_start_time"      : curRes.execution_start_time,
            "execution_end_time"        : curRes.execution_end_time,
            "store_closed"              : curRes.store_closed,
            "comment"                   : curRes.comment,
            "results"                   : resultArray,
            "positioning"               : dictPos
            ] as JsonDict
        
        _ = MYResult.resultDict.saveToFile(Current.resultFile)
    }
    
    func removeResultWithId (_ id: Int) {
        do {
            try? FileManager.default.removeItem(atPath: Current.resultFile)
        }
    }
}

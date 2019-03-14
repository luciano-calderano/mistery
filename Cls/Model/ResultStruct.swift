//
//  ResultStruct.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

struct JobResult {
    var id = 0
//    var estimate_date = "" // Date [aaaa-mm-dd]
    var compiled = 0 // Boolean [0/1]
    var compilation_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
    var updated = 0 // Boolean [0/1]
    var update_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
    var execution_date = "" // Date [aaaa-mm-dd]
    var execution_start_time = "" // Time [hh:mm]
    var execution_end_time = "" // Time [hh:mm]
    var store_closed = 0 // Boolean [0/1]
    var comment = ""
    var results = [KpiResult]()
    var positioning = PositioningResult()
    
    class KpiResult {
        var kpi_id = 0
        var value = ""
        var notes = ""
        var attachment = ""
    }
    class PositioningResult  {
        var start = false
        var start_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        var start_lat:Double = 0
        var start_lng:Double = 0
        var end = false
        var end_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        var end_lat:Double = 0
        var end_lng:Double = 0
    }
}

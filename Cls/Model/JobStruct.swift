//
//  JobStruct.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

struct Job {
    var id = 0
    var reference = ""
    var store = Store()
    var description = ""
    var additional_description = ""
    var details = ""
    var start_date: Date! // = "" // Date [aaaa-mm-dd]
    var end_date: Date! //  = "" // Date [aaaa-mm-dd]
    var estimate_date: Date! //  = "" // Date [aaaa-mm-dd]
    var fee_desc = ""
    var status = ""
    var booking_date: Date! // = "" //Date and Time [aaaa-mm-dd hh:mm:ss]
    var irregular = false
    var notes = ""
    var positioning = Positioning() // Object
    var execution_date: Date? //  = "" // Date [aaaa-mm-dd]
    var execution_start_time = "" // Time [hh:mm]
    var execution_end_time = "" // Time [hh:mm]
    var comment = ""
    var comment_min = 0
    var comment_max = 0
    var attachments = [Attachment]()
    var kpis = [Kpi]()
    var learning_done = false
    var learning_url = ""
    var store_closed = false
    
    //MARK: -
    
    class Store {
        var name = ""
        var type = ""
        var address = ""
        var latitude: Double = 0 // Numeric
        var longitude: Double = 0
    }
    
    //MARK: -
    
    class Attachment {
        var id = 0
        var filename = ""
        var name = ""
        var url = ""
    }
    
    //MARK: -
    
    class Positioning  {
        var required = false
        var start = false
        var start_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        var start_lat:Double = 0
        var start_lng:Double = 0
        var end = false
        var end_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        var end_lat:Double = 0
        var end_lng:Double = 0
    }
    
    //MARK: -
    
    class Kpi {
        var isValid = true

        var id = 0
        var name = ""
        var section = 0
        var note = ""
        var section_id = 0
        var required = false
        var note_required = false
        var note_error_message = ""
        var attachment = false
        var attachment_required = false
        var attachment_error_message = ""
        var type = ""
        var order = 0
        var factor = ""
        var service = ""
        var standard = ""
        var instructions = ""
        var valuations = [Valuation]()
        var result = Result()
        class Result {
            var id = 0
            var value = ""
            var notes = ""
            var attachment = ""
            var url = ""
            var irregular = false
            var irregular_note = ""
        }
        class Valuation {
            var id = 0
            var name = ""
            var order = 0
            var positive = false
            var note_required = false
            var attachment_required = false
            var dependencies = [Dependency]()
            class Dependency {
                var key = 0
                var value = ""
                var notes = ""
            }
        }
    }
}

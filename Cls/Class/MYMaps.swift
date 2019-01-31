//
//  MYMaps.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class Maps {
    init(lat: Double, lon: Double, name: String) {
        if lat == 0 || lon == 0 {
            return
        }
        let name = name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let page = "ll=\(lat),\(lon)&q=" + name + "&z=10"
        let url = URL(string: Config.Url.maps + page)!
        let options = [UIApplication.OpenExternalURLOptionsKey: Any]()
        UIApplication.shared.open(url, options: options, completionHandler: nil)
    }
}

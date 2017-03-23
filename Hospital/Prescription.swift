//
//  File.swift
//  Hospital
//
//  Created by Simone Montalto on 23/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation

class Prescription {
    
    var name: String
    var date: String
    var hour: String
    
    init(name: String, date: String, hour: String) {
        self.name = name
        self.date = date
        self.hour = hour
    }
    
}

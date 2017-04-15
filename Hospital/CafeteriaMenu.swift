//
//  File.swift
//  Hospital
//
//  Created by Simone Montalto on 15/04/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation

struct CafeteriaMenu {
    
    var firstDishes: [String]?
    var secondDishes: [String]?
    var lastYear: Int?
    var lastMonth: Int?
    var lastDay: Int?
    var lastDayName: String?
    var lastType: String?
    var newMenu: Bool?
    
    init() {
        firstDishes = nil
        secondDishes = nil
        lastYear = nil
        lastMonth = nil
        lastDay = nil
        lastDayName = nil
        lastType = nil
        newMenu = nil
    }
    
}

//
//  CafeteriaData.swift
//  Hospital
//
//  Created by Simone Montalto on 15/04/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation
import UIKit

class CafeteriaData {
    
    static let defaults = UserDefaults.standard
    static var menu = CafeteriaMenu()
    
    static func getData() -> CafeteriaMenu {
        
        if defaults.integer(forKey: UserDefaultsKeys.lastYearKey) != 0 {
            menu.lastYear = defaults.integer(forKey: UserDefaultsKeys.lastYearKey)
        }
        if defaults.integer(forKey: UserDefaultsKeys.lastMonthKey) != 0 {
            menu.lastMonth = defaults.integer(forKey: UserDefaultsKeys.lastMonthKey)
        }
        if defaults.integer(forKey: UserDefaultsKeys.lastDayKey) != 0 {
            menu.lastDay = defaults.integer(forKey: UserDefaultsKeys.lastDayKey)
        }
        menu.lastType = defaults.string(forKey: UserDefaultsKeys.lastTypeKey)
        
        loadDishes()
        return menu
    }
    
    static func loadDishes() {
        
        if let path = Bundle.main.path(forResource: "json/cafeteria-lunch", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) {
                let json = JSON(data: data)
                parse(json: json)
            }
        }
    }
    
    static func parse(json: JSON) {
        
        menu.firstDishes = json["first_dish"].arrayObject as? [String]
        menu.secondDishes = json["second_dish"].arrayObject as? [String]
        
        if let lastYear = menu.lastYear {
            if let lastMonth = menu.lastMonth {
                if let lastDay = menu.lastDay {
                    if let lastType = menu.lastType {
                        if lastYear == json["year"].intValue && lastMonth == json["month"].intValue && lastDay == json["day"].intValue && lastType == json["type"].stringValue {
                            menu.newMenu = false
                        } else {
                            menu.newMenu = true
                        }
                    } else {
                        menu.newMenu = true
                    }
                } else {
                    menu.newMenu = true
                }
            } else {
                menu.newMenu = true
            }
        } else {
            menu.newMenu = true
        }
        menu.lastYear = json["year"].intValue
        menu.lastMonth = json["month"].intValue
        menu.lastDay = json["day"].intValue
        menu.lastDayName = json["day_name"].stringValue
        menu.lastType = json["type"].stringValue
        defaults.setValue(menu.lastYear, forKey: UserDefaultsKeys.lastYearKey)
        defaults.setValue(menu.lastMonth, forKey: UserDefaultsKeys.lastMonthKey)
        defaults.setValue(menu.lastDay, forKey: UserDefaultsKeys.lastDayKey)
        defaults.setValue(menu.lastDayName, forKey: UserDefaultsKeys.lastDayNameKey)
        defaults.setValue(menu.lastType, forKey: UserDefaultsKeys.lastTypeKey)
        defaults.synchronize()
    }
}

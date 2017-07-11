//
//  MedicalExaminationSection.swift
//  Hospital
//
//  Created by Simone Montalto on 19/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation

class TableViewSection {
    
    var heading: String
    var items: [Any]
    
    init(title: String, objects: [Any]) {
        self.heading = title
        self.items = objects
    }
    
}

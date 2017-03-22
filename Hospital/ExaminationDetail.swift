//
//  ExaminationDetail.swift
//  Hospital
//
//  Created by Simone Montalto on 20/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation

struct ExaminationDetail {
    
    var name: String
    var date: String
    var hour: String
    var examinationDescription: String
    var doctor: String
    var POI_ID: String
    
    init(name: String, date: String, hour: String, examinationDescription: String, doctor: String, POI_ID: String) {
        self.name = name
        self.date = date
        self.hour = hour
        self.examinationDescription = examinationDescription
        self.doctor = doctor
        self.POI_ID = POI_ID
    }

}

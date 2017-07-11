//
//  POIDetail.swift
//  Hospital
//
//  Created by Simone Montalto on 22/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class POIDetail {
    
    var ID: String
    var name: String
    var hour: String
    var POIDescription: String
    var manager: String
    var building: String
    var coordinates: CGPoint
    var phoneNumber: String
    
    init(ID: String, name: String, hour: String, description: String, manager: String, building: String, phoneNumber: String, coordinates: CGPoint) {
        self.ID = ID
        self.name = name
        self.hour = hour
        self.POIDescription = description
        self.manager = manager
        self.building = building
        self.phoneNumber = phoneNumber
        self.coordinates = coordinates
    }
    
}

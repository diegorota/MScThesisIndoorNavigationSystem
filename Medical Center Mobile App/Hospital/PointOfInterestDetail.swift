//
//  PointOfInterestDetail.swift
//  Hospital
//
//  Created by Simone Montalto on 20/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class PointOfInterestDetail: NSObject {
    
    var name: String
    var openingHours: String
    var poiDescription: String
    var manager: String
    var coordinates: CGPoint
    var place: String
    
    init(name: String, openingHours: String, poiDescription: String, manager: String, coordinates: CGPoint, place: String) {
        self.name = name
        self.openingHours = openingHours
        self.poiDescription = poiDescription
        self.manager = manager
        self.coordinates = coordinates
        self.place = place
    }

}

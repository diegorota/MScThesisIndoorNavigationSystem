//
//  HomeTile.swift
//  Hospital
//
//  Created by Simone Montalto on 15/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class HomeTile: NSObject {
    
    var titleTile: String
    var descriptionTile: String
    var callToActionTile: String
    var logoTile: String
    var dimensionTile: Int
    
    init(titleTile: String, descriptionTile: String, callToActionTile: String, logoTile: String, dimensionTile: Int) {
        
        self.titleTile = titleTile
        self.descriptionTile = descriptionTile
        self.callToActionTile = callToActionTile
        self.logoTile = logoTile
        self.dimensionTile = dimensionTile
        
    }

}

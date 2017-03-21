//
//  ExaminationInformation.swift
//  Hospital
//
//  Created by Simone Montalto on 21/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class ExaminationInformation: NSObject {

    var title: String
    var information: String
    
    init(title: String, information: String) {
        self.title = title
        self.information = information
    }
    
}

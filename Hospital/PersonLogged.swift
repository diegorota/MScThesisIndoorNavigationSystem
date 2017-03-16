//
//  PersonLogged.swift
//  Hospital
//
//  Created by Simone Montalto on 16/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class PersonLogged: NSObject {
    
    static var name: String = ""
    static var surname: String = ""
    static var fiscalCode: String = ""
    static var hospitalized: Bool = false
    static var keepLogin: Bool = false
    
    static func clearAll() {
        name = ""
        surname = ""
        fiscalCode = ""
        hospitalized = false
        keepLogin = false
        
    }

}

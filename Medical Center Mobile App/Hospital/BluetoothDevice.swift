//
//  BluetoothDevice.swift
//  Hospital
//
//  Created by Simone Montalto on 22/04/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation

struct BluetoothDevice {
    let name: String
    let uuid: String
    
    init(name: String, uuid: String) {
        self.name = name
        self.uuid = uuid
    }
}

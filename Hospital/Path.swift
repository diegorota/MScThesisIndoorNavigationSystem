//
//  Path.swift
//  Hospital
//
//  Created by Simone Montalto on 11/05/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation

class Path {
    var total: Int!
    var destination: Vertex
    var previous: Path!
    
    init() {
        self.destination = Vertex()
    }
    
}

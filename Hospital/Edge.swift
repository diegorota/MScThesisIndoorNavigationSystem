//
//  Edge.swift
//  Hospital
//
//  Created by Simone Montalto on 10/05/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation

class Edge {
    
    var neighbor: Vertex
    var weight: Int
    var direction: Int
    
    init() {
        weight = 0
        self.neighbor = Vertex()
        self.direction = Int()
    }
    
}

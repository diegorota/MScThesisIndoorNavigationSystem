//
//  Vertex.swift
//  Hospital
//
//  Created by Simone Montalto on 10/05/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation
import UIKit

class Vertex {
    var key: String?
    var position: CGPoint
    var neighbors: Array<Edge>
    
    init() {
        self.neighbors = Array<Edge>()
        self.position = CGPoint()
    }
}

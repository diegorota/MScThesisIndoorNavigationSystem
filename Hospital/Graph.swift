//
//  Graph.swift
//  Hospital
//
//  Created by Simone Montalto on 10/05/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation
import UIKit

class Graph {
    
    var canvas: Array<Vertex>
    var isDirected: Bool
    
    init() {
        self.canvas = Array<Vertex>()
        isDirected = true
    }
    
    func addVertex(key: String, position: CGPoint) -> Vertex {
        
        var childVertex: Vertex = Vertex()
        childVertex.key = key
        childVertex.position = position
        canvas.append(childVertex)
        return childVertex
        
    }
    
    func addEdge(source: Vertex, neighbor: Vertex, weight: Int, direction: Int) {
        
        // arco A -> B
        var newEdge = Edge()
        newEdge.neighbor = neighbor
        newEdge.weight = weight
        newEdge.direction = direction
        source.neighbors.append(newEdge)
        
    }
    
}

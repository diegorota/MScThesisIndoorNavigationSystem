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
    var edges: Array<Edge>
    var isDirected: Bool
    
    init() {
        self.canvas = Array<Vertex>()
        self.edges = Array<Edge>()
        isDirected = true
    }
    
    func addVertex(key: String, position: CGPoint) -> Vertex {
        
        let childVertex: Vertex = Vertex()
        childVertex.key = key
        childVertex.position = position
        canvas.append(childVertex)
        return childVertex
        
    }
    
    func addVertex(key: String, position: CGPoint, isPOI: Bool) -> Vertex {
        
        let childVertex: Vertex = Vertex()
        childVertex.key = key
        childVertex.position = position
        childVertex.isPOI = isPOI
        canvas.append(childVertex)
        return childVertex
        
    }
    
    func addVertex(key: String, position: CGPoint, isPOI: Bool, obstacle: Bool) -> Vertex {
        
        let childVertex: Vertex = Vertex()
        childVertex.key = key
        childVertex.position = position
        childVertex.isPOI = isPOI
        childVertex.obstacle = obstacle
        canvas.append(childVertex)
        return childVertex
        
    }
    
    func addVertex(key: String, position: CGPoint, obstacle: Bool) -> Vertex {
        
        let childVertex: Vertex = Vertex()
        childVertex.key = key
        childVertex.position = position
        childVertex.obstacle = obstacle
        canvas.append(childVertex)
        return childVertex
        
    }
    
    func addEdge(source: Vertex, neighbor: Vertex, weight: Int, direction: String) {
        
        // arco A -> B
        let newEdge = Edge()
        newEdge.neighbor = neighbor
        newEdge.weight = weight
        newEdge.direction = direction
        source.neighbors.append(newEdge)
        edges.append(newEdge)
        
    }
    
    func addExistingEdge(source: Vertex, edge: Edge) {
        for v in canvas {
            if v.key == source.key {
                v.neighbors.append(edge)
            }
        }
        edges.append(edge)
    }
    
    func processDijkstra(source: Vertex, destination: Vertex, vertices: Array<Vertex>) -> Graph? {
        var vertexAlreadySeen: Array<Vertex> = Array<Vertex>()
        vertexAlreadySeen.append(source)
        var frontier: Array<Path> = Array<Path>()
        var finalPaths: Array<Path> = Array<Path>()
        //use source edges to create the frontier
        for e in source.neighbors {
            let newPath: Path = Path()
            newPath.destination = e.neighbor
            newPath.previous = nil
            newPath.total = e.weight
            //add the new path to the frontier
            vertexAlreadySeen.append(newPath.destination)
            frontier.append(newPath)
        }
        
        //obtain the best path
        var bestPath: Path = Path()
        while(frontier.count != 0) {
            print(frontier.count)
            //support path changes using the greedy approach
            bestPath = Path()
            var pathIndex: Int = 0
            for x in 0..<frontier.count {
                let itemPath: Path = frontier[x] as Path
                if (bestPath.total == nil) || (itemPath.total < bestPath.total) {
                    bestPath = itemPath
                    pathIndex = x
                }
            }
            
            for e in bestPath.destination.neighbors {
                let newPath: Path = Path()
                newPath.destination = e.neighbor
                newPath.previous = bestPath
                newPath.total = bestPath.total + e.weight
                
                //add the new path to the frontier
                var insert = true
                for v in vertexAlreadySeen {
                    if v.key == newPath.destination.key {
                        insert = false
                    }
                }
                if insert {
                    vertexAlreadySeen.append(newPath.destination)
                    frontier.append(newPath)
                }
            }
            //preserve the bestPath
            finalPaths.append(bestPath)
            //remove the bestPath from the frontier
            frontier.remove(at: pathIndex)
        }
        printSeperator(content: "FINALPATHS")
        printPaths(paths: finalPaths as [Path], source: source)
        printSeperator(content: "BESTPATH BEFORE")
        printPath(path: bestPath, source: source)
        if finalPaths.count == 0 {
            return nil
        } else {
            bestPath = Path()
            for p in finalPaths {
                let path = p as Path
                if (bestPath.total == nil) && (path.destination.key == destination.key) || (bestPath.total != nil) && (path.total < bestPath.total) && (path.destination.key == destination.key){
                    bestPath = path
                }
            }
            if bestPath.total == nil {
                return nil
            }
            printSeperator(content: "BESTPATH AFTER")
            printPath(path: bestPath, source: source)
            return pathToGraph(path: bestPath, source: source, vertices: vertices)
        }
    }
    
    func pathToGraph(path: Path, source: Vertex, vertices: Array<Vertex>) -> Graph {
        var bestVertices = Array<Vertex>()
        let graph = Graph()
        bestVertices.append(path.destination)
        var previousPath = path.previous
        while previousPath != nil {
            bestVertices.insert((previousPath?.destination)!, at: 0)
            previousPath = previousPath?.previous
        }
        bestVertices.insert(source, at: 0)
        
        for v in bestVertices {
            _ = graph.addVertex(key: v.key!, position: v.position, isPOI: v.isPOI, obstacle: v.obstacle)
        }
        
        for x in 0..<bestVertices.count-1 {
            for v in vertices {
                if v.key! == bestVertices[x].key! {
                    for e in v.neighbors {
                        if e.neighbor.key! == bestVertices[x+1].key! {
                            graph.addExistingEdge(source: bestVertices[x], edge: e)
                        }
                    }
                }
            }
        }
        return graph
    }
    
    func printPath(path: Path, source: Vertex) {
        print("BP: weight- \(path.total) \(path.destination.key!) ")
        if path.previous != nil {
            printPath(path: path.previous!, source: source)
        } else {
            print("Source : \(source.key!)")
        }
    }
    
    func printPaths(paths: [Path], source: Vertex) {
        for path in paths {
            printPath(path: path, source: source)
        }
    }
    
    func printLine() {
        print("*******************************")
    }
    
    func printSeperator(content: String) {
        printLine()
        print(content)
        printLine()
    }
    
}

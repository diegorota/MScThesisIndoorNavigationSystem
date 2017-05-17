//
//  MapViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 23/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit
import CoreBluetooth
import AVFoundation

class DepartmentMapViewController: UIViewController, UIScrollViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, SelectPlaceViewControllerDelegate, AVAudioPlayerDelegate {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var mapScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var errorMessageView: UIView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var selectDestinationView: SelectDestinationView!
    @IBOutlet weak var navigationView: NavigationView!
    
    // View della freccia e della bandiera
    var arrowView: UIView!
    var flagView: UIView? = nil
    
    // Variabili necessarie per la gestione del bluetooth
    var centralManager:CBCentralManager!
    var arduinoPeripherals:CBPeripheral?
    var arduinoCharacteristic:CBCharacteristic?
    
    //let identifier = "3CF2AC85-97E2-4346-8A4B-DE1398DB9B37"
    var identifier: String!
    let RBL_SERVICE_UUID = "713D0000-503E-4C75-BA94-3148F18D941E"
    let RBL_CHAR_TX_UUID = "713D0002-503E-4C75-BA94-3148F18D941E"
    let RBL_CHAR_RX_UUID = "713D0003-503E-4C75-BA94-3148F18D941E"
    var tagName = ""
    
    var lastString = ""
    var initialPacket = true
    
    let timerPauseInterval:TimeInterval = 10.0
    let timerScanInterval:TimeInterval = 2.0
    var keepScanning = false
    
    // Variabili necessarie per zoom e posizione freccia su mappa
    var minZoom: Double!
    var maxZoom: Double!
    let realRoomWidth:CGFloat = 17000
    let realRoomHeight:CGFloat = 21750
    var imageWidth: CGFloat!
    var imageHeight: CGFloat!
    //var lastPosition: CGPoint?
    var lastPosition: CGPoint? = CGPoint(x: 240, y: 440)
    var lastHeading: CGFloat?
    var firstPosition = true
    
    // Variabile filtro di Kalman
    var kalmanFilter: KalmanFilter?
    
    // Variabili navigatore
    var allGraph: Graph!
    var bestGraph: Graph?
    var maximumDistance: CGFloat!
    var startingVertex: Vertex?
    var destinationVertex: Vertex?
    var originalImage: UIImage!
    var up: AVAudioPlayer?
    var left: AVAudioPlayer?
    var right: AVAudioPlayer?
    var obstacle: AVAudioPlayer?
    var finish: AVAudioPlayer?
    var lastDirection: String  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapScrollView.delegate = self
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.errorMessageView.isHidden = true
        self.errorMessageView.alpha = 0
        self.errorMessageView.backgroundColor = Colors.mediumColor
        
        // Memorizzo altezza e larghezza dell'immagine. Verranno usate per le proporzioni dello zoom della mappa
        imageWidth = imageView.frame.width
        imageHeight = imageView.frame.height
        
        // Chiamo la funzione per adattare lo zoom della mappa alla larghezza del display
        setMapZoom(size: view.frame.size)
        
        // Setto riconoscimento doppio tocco per effettuare zoom
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoom))
        tap.numberOfTapsRequired = 2
        mapScrollView.addGestureRecognizer(tap)
        
        // Setto view navigation & stopNavigationButton
        selectDestinationView.backgroundView.backgroundColor = Colors.mediumColor
        selectDestinationView.destinationButton.tintColor = Colors.darkColor
        selectDestinationView.navigateButton.isEnabled = false
        navigationView.backgroundView.backgroundColor = Colors.mediumColor
        navigationView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        
        maximumDistance = 2000*(imageView.image?.size.width)!/realRoomWidth
        print("maximum distance: \(maximumDistance)")
        
        self.allGraph = self.initializeGraph()
        originalImage = self.imageView.image!
        //self.imageView.image = self.drawLines(size: self.imageView.image!.size, image: self.imageView.image!, graph: self.allGraph, color: UIColor.blue)
        
        // Setto audio navigatore
        initializeSounds()
        
    }
    
    func getNearestVertex(position: CGPoint, graph: Graph) -> Vertex? {
        var lessDistance: CGFloat? = nil
        var nearestVertex: Vertex? = nil
        
        for v in (graph.canvas) {
            let distance = CGPointDistance(from: position, to: v.position)
            print(distance)
            if lessDistance == nil {
                if distance < maximumDistance {
                    lessDistance = distance
                    nearestVertex = v
                }
            } else {
                if distance < lessDistance! && distance < maximumDistance {
                    lessDistance = distance
                    nearestVertex = v
                }
            }
        }
        
        return nearestVertex
        
    }
    
    func initializeSounds() {
        let upUrl = URL.init(fileURLWithPath: Bundle.main.path(
            forResource: "up",
            ofType: "m4a")!)
        
        do {
            try up = AVAudioPlayer(contentsOf: upUrl)
            up?.delegate = self
            up?.prepareToPlay()
        } catch let error as NSError {
            print("audioPlayer error \(error.localizedDescription)")
        }
        
        let rightUrl = URL.init(fileURLWithPath: Bundle.main.path(
            forResource: "right",
            ofType: "m4a")!)
        
        do {
            try right = AVAudioPlayer(contentsOf: rightUrl)
            right?.delegate = self
            right?.prepareToPlay()
        } catch let error as NSError {
            print("audioPlayer error \(error.localizedDescription)")
        }
        
        let leftUrl = URL.init(fileURLWithPath: Bundle.main.path(
            forResource: "left",
            ofType: "m4a")!)
        
        do {
            try left = AVAudioPlayer(contentsOf: leftUrl)
            left?.delegate = self
            left?.prepareToPlay()
        } catch let error as NSError {
            print("audioPlayer error \(error.localizedDescription)")
        }
        
        let obstacleUrl = URL.init(fileURLWithPath: Bundle.main.path(
            forResource: "obstacle",
            ofType: "m4a")!)
        
        do {
            try obstacle = AVAudioPlayer(contentsOf: obstacleUrl)
            obstacle?.delegate = self
            obstacle?.prepareToPlay()
        } catch let error as NSError {
            print("audioPlayer error \(error.localizedDescription)")
        }
        
        let finishUrl = URL.init(fileURLWithPath: Bundle.main.path(
            forResource: "finish",
            ofType: "m4a")!)
        
        do {
            try finish = AVAudioPlayer(contentsOf: finishUrl)
            finish?.delegate = self
            finish?.prepareToPlay()
        } catch let error as NSError {
            print("audioPlayer error \(error.localizedDescription)")
        }
    }
    
    func directionToString(direction: String) -> String {
        switch direction {
        case Direction.left.rawValue:
            return "turn left"
        case Direction.right.rawValue:
            return "turn right"
        case Direction.straight.rawValue:
            return "go straight on"
        default:
            return "error"
        }
    }
    
    func navigation(position: CGPoint, heading: CGFloat, graph: Graph) {
        
        let nearestVertex = getNearestVertex(position: position, graph: bestGraph!)
    
        if let nearestVertex = nearestVertex {
            updateMap(x: nearestVertex.position.x, y: nearestVertex.position.y, heading: CGFloat(180)+heading)
            
            if nearestVertex.neighbors.count != 0 {
                
                var direction = directionToString(direction: nearestVertex.neighbors[0].direction)
                if nearestVertex.obstacle {
                    direction = direction + ".\nObstacle!"
                    navigationView.backgroundView.backgroundColor = UIColor.orange
                    if let obstacle = obstacle {
                        obstacle.play()
                    }
                } else {
                    navigationView.backgroundView.backgroundColor = Colors.mediumColor
                }
                print(direction)
                navigationView.labelDirection.text = direction.uppercased()
                navigationView.imageDirection.image = UIImage(named: nearestVertex.neighbors[0].direction)
                
                if lastDirection != nearestVertex.neighbors[0].direction && nearestVertex.neighbors[0].direction == Direction.straight.rawValue {
                    lastDirection = nearestVertex.neighbors[0].direction
                    if let up = up {
                        up.play()
                    }
                } else if lastDirection != nearestVertex.neighbors[0].direction && nearestVertex.neighbors[0].direction == Direction.left.rawValue {
                    lastDirection = nearestVertex.neighbors[0].direction
                    if let left = left {
                        left.play()
                    }
                } else if lastDirection != nearestVertex.neighbors[0].direction && nearestVertex.neighbors[0].direction == Direction.right.rawValue {
                    lastDirection = nearestVertex.neighbors[0].direction
                    if let right = right {
                        right.play()
                    }
                }
                
            } else {
                let direction = "\(nearestVertex.key!). You are arrived!"
                print(direction)
                navigationView.labelDirection.text = direction.uppercased()
                
                if let finish = finish {
                    finish.play()
                }
                stopNavigation()
                
            }
        } else {
            
            updateMap(x: position.x, y: position.y, heading: CGFloat(180)+heading)
            
            navigationView.backgroundView.backgroundColor = UIColor.red
            let direction = "Searching for the optimal route"
            print(direction)
            navigationView.labelDirection.text = direction.uppercased()
            
            DispatchQueue.global(qos: .userInitiated).async {
                sleep(3)
                DispatchQueue.main.async {
                    let currentNearestPosition = self.getNearestVertex(position: position, graph: self.allGraph)
                    if let currentNearestPosition = currentNearestPosition {
                        if let destinationVertex = self.destinationVertex {
                            
                            self.imageView.image = self.originalImage
                            self.searchBestPath(startingPoint: currentNearestPosition, destinationPoint: destinationVertex, graph: self.allGraph)
                        }
                    }
                }
            }
        }
    }
    
    func drawLines(size: CGSize, image: UIImage, graph: Graph, color: UIColor) -> UIImage? {
        
        UIGraphicsBeginImageContext(size)
        image.draw(at: CGPoint.zero)
        
        for vertex in graph.canvas {
            for edge in vertex.neighbors {
                if let context = UIGraphicsGetCurrentContext() {
                    context.setLineWidth(5.0)
                    context.setStrokeColor(color.cgColor)
                    context.move(to: vertex.position)
                    context.addLine(to: edge.neighbor.position)
                    context.closePath()
                    context.strokePath()
                }
            }
        }
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    func searchBestPath(startingPoint: Vertex, destinationPoint: Vertex, graph: Graph) {
        bestGraph = allGraph.processDijkstra(source: startingPoint, destination: destinationPoint, vertices: graph.canvas)
        if let bestGraph = bestGraph {
            self.imageView.image = self.drawLines(size: self.imageView.image!.size, image: self.imageView.image!, graph: bestGraph, color: UIColor.green)
            addFlagToMap(position: destinationPoint.position)
            
        }
    }
    
    func initializeGraph() -> Graph {
        let graph = Graph()
        
        let g1 = graph.addVertex(key: "Prof. Ardagna", position: CGPoint(x: 104, y: 402), isPOI: true)
		let g2 = graph.addVertex(key: "Prof. Baresi", position: CGPoint(x: 103, y: 348), isPOI: true)
		let g3 = graph.addVertex(key: "Prof. Sbattella", position: CGPoint(x: 104, y: 218), isPOI: true)
		let g4 = graph.addVertex(key: "PhD", position: CGPoint(x: 93, y: 125), isPOI: true)
		let g5 = graph.addVertex(key: "Prof. Guinea & Mottola", position: CGPoint(x: 84, y: 81), isPOI: true)
		let g6 = graph.addVertex(key: "Prof. Fuggetta", position: CGPoint(x: 121, y: 94), isPOI: true)
		let g7 = graph.addVertex(key: "Archive", position: CGPoint(x: 196, y: 150), isPOI: true)
		let g8 = graph.addVertex(key: "Prof. Morzenti", position: CGPoint(x: 252, y: 96), isPOI: true)
		let g9 = graph.addVertex(key: "Prof. Pradella", position: CGPoint(x: 289, y: 81), isPOI: true)
		let g10 = graph.addVertex(key: "Prof. Rossi", position: CGPoint(x: 283, y: 122), isPOI: true)
		let g11 = graph.addVertex(key: "Software lab", position: CGPoint(x: 184, y: 289), isPOI: true)
        let g12 = graph.addVertex(key: "Bathroom", position: CGPoint(x: 271, y: 480), isPOI: true)
		let g13 = graph.addVertex(key: "Printing room", position: CGPoint(x: 196, y: 408), isPOI: true)
		
		//CORRIDOIO BARESI
		let z0a = graph.addVertex(key: "z0a", position: CGPoint(x: 124, y: 366))
		let z0b = graph.addVertex(key: "z0b", position: CGPoint(x: 124, y: 385))
		//let z0c = graph.addVertex(key: "z0c", position: CGPoint(x: 124, y: 403))
		let z0d = graph.addVertex(key: "z0d", position: CGPoint(x: 124, y: 423))
		//let z1 = graph.addVertex(key: "z1", position: CGPoint(x: 124, y: 348))
		let z2 = graph.addVertex(key: "z2", position: CGPoint(x: 124, y: 326))
		let z3 = graph.addVertex(key: "z3", position: CGPoint(x: 124, y: 304))
		let z4 = graph.addVertex(key: "z4", position: CGPoint(x: 124, y: 284))
		let z5 = graph.addVertex(key: "z5", position: CGPoint(x: 124, y: 264))
		let z6 = graph.addVertex(key: "z6", position: CGPoint(x: 124, y: 242))
		let z7 = graph.addVertex(key: "z7", position: CGPoint(x: 124, y: 218))
		let z8 = graph.addVertex(key: "z8", position: CGPoint(x: 124, y: 200))
		let z9 = graph.addVertex(key: "z9", position: CGPoint(x: 124, y: 180))
		let z10 = graph.addVertex(key: "z10", position: CGPoint(x: 124, y: 160))
		let z11 = graph.addVertex(key: "z11", position: CGPoint(x: 124, y: 140))
		//CORRIDOIO MORZENTI 
		//let z12 = graph.addVertex(key: "z12", position: CGPoint(x: 124, y: 126))
		let z13 = graph.addVertex(key: "z13", position: CGPoint(x: 112, y: 116))
		//let z14 = graph.addVertex(key: "z14", position: CGPoint(x: 100, y: 105))
		let z14 = graph.addVertex(key: "z14", position: CGPoint(x: 89, y: 94))
		let z16 = graph.addVertex(key: "z16", position: CGPoint(x: 142, y: 126))
        let z17 = graph.addVertex(key: "z17", position: CGPoint(x: 160, y: 126), obstacle: true)
		let z18 = graph.addVertex(key: "z18", position: CGPoint(x: 178, y: 126), obstacle: true)
		//let z19 = graph.addVertex(key: "z19", position: CGPoint(x: 195, y: 126))
		let z20 = graph.addVertex(key: "z20", position: CGPoint(x: 212, y: 126), obstacle: true)
		let z21 = graph.addVertex(key: "z21", position: CGPoint(x: 230, y: 126))
		//let z22 = graph.addVertex(key: "z22", position: CGPoint(x: 247, y: 126))
		let z23 = graph.addVertex(key: "z23", position: CGPoint(x: 258, y: 118))
		//let z24 = graph.addVertex(key: "z24", position: CGPoint(x: 271, y: 107))
		let z25 = graph.addVertex(key: "z25", position: CGPoint(x: 281, y: 96))
		//CORRIDOIO ROSSI
        let z26 = graph.addVertex(key: "z26", position: CGPoint(x: 247, y: 423))
        let z27 = graph.addVertex(key: "z27", position: CGPoint(x: 247, y: 403))
        let z28 = graph.addVertex(key: "z28", position: CGPoint(x: 247, y: 385))
		let z29 = graph.addVertex(key: "z29", position: CGPoint(x: 247, y: 366))
		let z30 = graph.addVertex(key: "z30", position: CGPoint(x: 247, y: 348))
		let z31 = graph.addVertex(key: "z31", position: CGPoint(x: 247, y: 326))
		let z32 = graph.addVertex(key: "z32", position: CGPoint(x: 247, y: 304))
		let z33 = graph.addVertex(key: "z33", position: CGPoint(x: 247, y: 284))
		let z34 = graph.addVertex(key: "z34", position: CGPoint(x: 247, y: 264))
		let z35 = graph.addVertex(key: "z35", position: CGPoint(x: 247, y: 242))
		let z36 = graph.addVertex(key: "z36", position: CGPoint(x: 247, y: 218))
		let z37 = graph.addVertex(key: "z37", position: CGPoint(x: 247, y: 200))
		let z38 = graph.addVertex(key: "z38", position: CGPoint(x: 247, y: 180))
		let z39 = graph.addVertex(key: "z39", position: CGPoint(x: 247, y: 160))
		let z40 = graph.addVertex(key: "z40", position: CGPoint(x: 247, y: 140))
		//CORRIDOIO STAMPANTE
		let z41 = graph.addVertex(key: "z41", position: CGPoint(x: 145, y: 433))
		let z42 = graph.addVertex(key: "z42", position: CGPoint(x: 164, y: 433))
		let z43 = graph.addVertex(key: "z43", position: CGPoint(x: 183, y: 433))
		let z44 = graph.addVertex(key: "z44", position: CGPoint(x: 202, y: 433))
		let z45 = graph.addVertex(key: "z45", position: CGPoint(x: 221, y: 433))
		let z46 = graph.addVertex(key: "z46", position: CGPoint(x: 240, y: 433))
        let z46a = graph.addVertex(key: "z46a", position: CGPoint(x: 240, y: 456))
        let z46b = graph.addVertex(key: "z46b", position: CGPoint(x: 240, y: 468))
        let z46c = graph.addVertex(key: "z46c", position: CGPoint(x: 240, y: 480))
		//INTERNO SALA TESISTI
		let z47 = graph.addVertex(key: "z47", position: CGPoint(x: 149, y: 337))
		let z48 = graph.addVertex(key: "z48", position: CGPoint(x: 167, y: 337))
		let z49 = graph.addVertex(key: "z49", position: CGPoint(x: 184, y: 337))
		let z50 = graph.addVertex(key: "z50", position: CGPoint(x: 184, y: 322))
		let z51 = graph.addVertex(key: "z51", position: CGPoint(x: 184, y: 307))
		let z52 = graph.addVertex(key: "z52", position: CGPoint(x: 184, y: 274))
		let z53 = graph.addVertex(key: "z53", position: CGPoint(x: 184, y: 256))
		let z54 = graph.addVertex(key: "z54", position: CGPoint(x: 184, y: 241))
		let z55 = graph.addVertex(key: "z55", position: CGPoint(x: 184, y: 227))
		let z56 = graph.addVertex(key: "z56", position: CGPoint(x: 207, y: 227))
		let z57 = graph.addVertex(key: "z57", position: CGPoint(x: 226, y: 227))
		
		//archi CORRIDOIO BARESI
		graph.addEdge(source: g2, neighbor: z2, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z2, neighbor: g2, weight: 1, direction: Direction.right.rawValue)
        graph.addEdge(source: g2, neighbor: z0a, weight: 1, direction: Direction.right.rawValue)
        graph.addEdge(source: z0a, neighbor: g2, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z2, neighbor: z0a, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z0a, neighbor: z2, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z0a, neighbor: z0b, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z0b, neighbor: z0a, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z0b, neighbor: z0d, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z0d, neighbor: z0b, weight: 1, direction: Direction.straight.rawValue)
		//graph.addEdge(source: z0c, neighbor: z0d, weight: 1, direction: Direction.straight.rawValue)
		//graph.addEdge(source: z0d, neighbor: z0c, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z0b, neighbor: g1, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: g1, neighbor: z0b, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: z0d, neighbor: g1, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: g1, neighbor: z0d, weight: 1, direction: Direction.right.rawValue)
		//graph.addEdge(source: z1, neighbor: z2, weight: 1, direction: Direction.straight.rawValue)
        //graph.addEdge(source: z2, neighbor: z1, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z2, neighbor: z3, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z3, neighbor: z2, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z3, neighbor: z4, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z4, neighbor: z3, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z4, neighbor: z5, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z5, neighbor: z4, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z5, neighbor: z6, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z6, neighbor: z5, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z6, neighbor: z7, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z7, neighbor: z6, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z7, neighbor: z8, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z8, neighbor: z7, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z8, neighbor: z9, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z9, neighbor: z8, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z9, neighbor: z10, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z10, neighbor: z9, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z10, neighbor: z11, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z11, neighbor: z10, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: g3, neighbor: z7, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z7, neighbor: g3, weight: 1, direction: Direction.left.rawValue)
		
		//archi ingresso sam
        graph.addEdge(source: z11, neighbor: z13, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z13, neighbor: z16, weight: 1, direction: Direction.left.rawValue)
		//graph.addEdge(source: z12, neighbor: z13, weight: 1, direction: Direction.left.rawValue)
		//graph.addEdge(source: z13, neighbor: z12, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z13, neighbor: z14, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z14, neighbor: z13, weight: 1, direction: Direction.straight.rawValue)
		//graph.addEdge(source: z14, neighbor: z15, weight: 1, direction: Direction.straight.rawValue)
		//graph.addEdge(source: z15, neighbor: z14, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z13, neighbor: g4, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: g4, neighbor: z13, weight: 1, direction: Direction.right.rawValue)
        graph.addEdge(source: z14, neighbor: g4, weight: 1, direction: Direction.right.rawValue)
        graph.addEdge(source: g4, neighbor: z14, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z13, neighbor: g6, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: g6, neighbor: z13, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: z14, neighbor: g6, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: g6, neighbor: z14, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: z14, neighbor: g5, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: g5, neighbor: z14, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z11, neighbor: z16, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: z16, neighbor: z11, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: z16, neighbor: z13, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: z16, neighbor: z17, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z17, neighbor: z16, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z17, neighbor: z18, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z18, neighbor: z17, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z18, neighbor: z20, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z20, neighbor: z18, weight: 1, direction: Direction.straight.rawValue)
		//graph.addEdge(source: z19, neighbor: z20, weight: 1, direction: Direction.straight.rawValue)
		//graph.addEdge(source: z20, neighbor: z19, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z20, neighbor: z21, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z21, neighbor: z20, weight: 1, direction: Direction.straight.rawValue)
		//graph.addEdge(source: z21, neighbor: z22, weight: 1, direction: Direction.straight.rawValue)
		//graph.addEdge(source: z22, neighbor: z21, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z21, neighbor: z23, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z23, neighbor: z21, weight: 1, direction: Direction.right.rawValue)
		//graph.addEdge(source: z23, neighbor: z24, weight: 1, direction: Direction.straight.rawValue)
		//graph.addEdge(source: z24, neighbor: z23, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z23, neighbor: z25, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z25, neighbor: z23, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z18, neighbor: g7, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: g7, neighbor: z18, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: z20, neighbor: g7, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: g7, neighbor: z20, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: z23, neighbor: g8, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: g8, neighbor: z23, weight: 1, direction: Direction.right.rawValue)
        graph.addEdge(source: z25, neighbor: g8, weight: 1, direction: Direction.right.rawValue)
        graph.addEdge(source: g8, neighbor: z25, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z23, neighbor: g10, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: g10, neighbor: z23, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: z25, neighbor: g10, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: g10, neighbor: z25, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: z25, neighbor: g9, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: g9, neighbor: z25, weight: 1, direction: Direction.straight.rawValue)
		
		//archi stampante
		graph.addEdge(source: z0d, neighbor: z41, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z41, neighbor: z0d, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: z41, neighbor: z42, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z42, neighbor: z41, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z42, neighbor: z43, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z43, neighbor: z42, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z43, neighbor: z44, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z44, neighbor: z43, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z44, neighbor: z45, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z45, neighbor: z44, weight: 1, direction: Direction.straight.rawValue)
		//graph.addEdge(source: z45, neighbor: z46, weight: 1, direction: Direction.straight.rawValue)
		//graph.addEdge(source: z46, neighbor: z45, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z44, neighbor: g13, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: g13, neighbor: z44, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: z43, neighbor: g13, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: g13, neighbor: z43, weight: 1, direction: Direction.right.rawValue)
        graph.addEdge(source: z45, neighbor: z46a, weight: 2, direction: Direction.right.rawValue)
        graph.addEdge(source: z46a, neighbor: z45, weight: 2, direction: Direction.left.rawValue)
        graph.addEdge(source: z46a, neighbor: z46, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: z46, neighbor: z46a, weight: 1, direction: Direction.straight.rawValue)
		
		//archi corridoio ROSSI
        graph.addEdge(source: z26, neighbor: z46, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: z46, neighbor: z26, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: z46, neighbor: z46a, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: z46a, neighbor: z46, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z26, neighbor: z45, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: z45, neighbor: z26, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: z46a, neighbor: z46b, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: z46b, neighbor: z46a, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: z46b, neighbor: z46c, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: z46c, neighbor: z46b, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: z46c, neighbor: g12, weight: 1, direction: Direction.left.rawValue)
        graph.addEdge(source: g12, neighbor: z46c, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: z26, neighbor: z27, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z27, neighbor: z26, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z27, neighbor: z28, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z28, neighbor: z27, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z28, neighbor: z29, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z29, neighbor: z28, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z29, neighbor: z30, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z30, neighbor: z29, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z30, neighbor: z31, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z31, neighbor: z30, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z31, neighbor: z32, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z32, neighbor: z31, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z32, neighbor: z33, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z33, neighbor: z32, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z33, neighbor: z34, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z34, neighbor: z33, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z34, neighbor: z35, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z35, neighbor: z34, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z35, neighbor: z36, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z36, neighbor: z35, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z36, neighbor: z37, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z37, neighbor: z36, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z37, neighbor: z38, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z38, neighbor: z37, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z38, neighbor: z39, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z39, neighbor: z38, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z39, neighbor: z40, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z40, neighbor: z39, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z40, neighbor: z21, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z21, neighbor: z40, weight: 1, direction: Direction.right.rawValue)
        graph.addEdge(source: z40, neighbor: z23, weight: 1, direction: Direction.right.rawValue)
        graph.addEdge(source: z23, neighbor: z40, weight: 1, direction: Direction.left.rawValue)
//		graph.addEdge(source: z27, neighbor: g12, weight: 1, direction: Direction.right.rawValue)
//		graph.addEdge(source: g12, neighbor: z27, weight: 1, direction: Direction.left.rawValue)
//        graph.addEdge(source: z28, neighbor: g12, weight: 1, direction: Direction.left.rawValue)
//        graph.addEdge(source: g12, neighbor: z28, weight: 1, direction: Direction.right.rawValue)
		
		//archi sala tesisti
		graph.addEdge(source: z0a, neighbor: z47, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: z47, neighbor: z0a, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z2, neighbor: z47, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z47, neighbor: z2, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: z47, neighbor: z48, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z48, neighbor: z47, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z48, neighbor: z49, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z49, neighbor: z48, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z49, neighbor: z50, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z50, neighbor: z49, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z50, neighbor: z51, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z51, neighbor: z50, weight: 1, direction: Direction.straight.rawValue)		
		graph.addEdge(source: g11, neighbor: z51, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z51, neighbor: g11, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z52, neighbor: g11, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: g11, neighbor: z52, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z52, neighbor: z53, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z53, neighbor: z52, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z53, neighbor: z54, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z54, neighbor: z53, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z54, neighbor: z55, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z55, neighbor: z54, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z55, neighbor: z56, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: z56, neighbor: z55, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z56, neighbor: z57, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z57, neighbor: z56, weight: 1, direction: Direction.straight.rawValue)
		graph.addEdge(source: z57, neighbor: z35, weight: 1, direction: Direction.right.rawValue)
		graph.addEdge(source: z35, neighbor: z57, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z57, neighbor: z36, weight: 1, direction: Direction.left.rawValue)
		graph.addEdge(source: z36, neighbor: z57, weight: 1, direction: Direction.right.rawValue)
        
        return graph
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y);
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to));
    }
    
    func placeViewControllerDidSelect(value: Vertex?, kindOfButton: Int) {
        destinationVertex = value
        if let value = value {
            selectDestinationView.destinationButton.setTitle(value.key, for: .normal)
        } else {
            selectDestinationView.destinationButton.setTitle("Destination Point", for: .normal)
        }
        
        if let _ = destinationVertex {
            selectDestinationView.navigateButton.isEnabled = true
        } else {
            selectDestinationView.navigateButton.isEnabled = false
        }
    }
    
    func updateMap(x: CGFloat, y: CGFloat, heading: CGFloat) {
        //lastPosition = normalizePosition(meterX: x, meterY: y)
        lastPosition = CGPoint(x: x, y: y)
        
        lastHeading = heading
        
        if firstPosition {
            addArrowToMap()
            arrowView.center = lastPosition!
            arrowView.transform = CGAffineTransform(rotationAngle: lastHeading!)
            firstPosition = false
        } else {
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                self.arrowView.transform = CGAffineTransform(rotationAngle: (self.lastHeading!*CGFloat.pi)/180)
                self.arrowView.center = self.lastPosition!
            })
        }
    }
    
    //Funzione che genera la freccia che comparirà sulla mappa per mostrare posizione utente
    func addArrowToMap() {
        arrowView = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        let arrowImage = UIImageView()
        arrowImage.image = UIImage(named: "arrow")
        arrowView.addSubview(arrowImage)
        arrowImage.frame = CGRect(x:0,y:0,width:22,height:22)
        imageView.addSubview(arrowView)
    }
    
    //Funzione che genera la bandiera che comparirà sulla mappa per mostrare posizione di arrivo
    func addFlagToMap(position: CGPoint) {
        if flagView == nil {
            flagView = UIView(frame: CGRect(x: 0, y: 0, width: 33, height: 33))
            let flagImage = UIImageView()
            flagImage.image = UIImage(named: "flag")
            flagView?.addSubview(flagImage)
            flagImage.frame = CGRect(x:0,y:0,width:33,height:33)
            imageView.addSubview(flagView!)
        }
        flagView?.isHidden = false
        flagView?.center = CGPoint(x: position.x+16, y: position.y-16)
    }
    
    // Funzione che normalizza X e Y passate da Pozyx così da proiettarle sulla mappa (conversione da mm a pixel)
    func normalizePosition(meterX: CGFloat, meterY: CGFloat) -> CGPoint {
        let newX = meterX*(imageView.image?.size.width)!/realRoomWidth
        let newY = meterY*(imageView.image?.size.height)!/realRoomHeight
        return CGPoint(x: newX, y: normalizeYAxes(y: newY))
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // Funzione chiamata quando si effettua un doppio tocco sulla mappa. Gestisce lo zoom.
    func zoom(sender: UIGestureRecognizer) {
        if (mapScrollView.zoomScale < 1.5) {
            mapScrollView.setZoomScale(mapScrollView.maximumZoomScale, animated: true)
        } else {
            mapScrollView.setZoomScale(mapScrollView.minimumZoomScale, animated: true)
        }
        
    }
    
    // Funzione che inverte l'asse Y
    func normalizeYAxes(y: CGFloat) -> CGFloat {
        return CGFloat(imageHeight-y)
    }
    
    // Funzione che setta zoom massimo e minimo della mappa così da occupare sempre l'intera larghezza del diaplay.
    func setMapZoom(size: CGSize) {
        minZoom = Double(size.width.divided(by: CGFloat(imageWidth!)))
        maxZoom = 3*minZoom
        self.mapScrollView.minimumZoomScale = CGFloat(minZoom)
        self.mapScrollView.maximumZoomScale = CGFloat(maxZoom)
        self.mapScrollView.zoomScale = CGFloat(minZoom)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Department Map"
        UIApplication.shared.isIdleTimerDisabled = true
        identifier = defaults.string(forKey: UserDefaultsKeys.uuidDeviceKey)
        
//        if identifier == "" {
//            let ac = UIAlertController(title: "Error", message: "There aren't bluetooth devices paired. Select 'Pair' to do the pairing.", preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "Pair", style: .default, handler: { (UIAlertAction) in
//                if let pairing = self.storyboard?.instantiateViewController(withIdentifier: "Pairing") {
//                    self.navigationController?.pushViewController(pairing, animated: true)
//                }
//            }))
//            ac.addAction(UIAlertAction(title: "Go Home", style: .default, handler: { (UIAlertAction) in
//                if let newView = self.storyboard?.instantiateViewController(withIdentifier: "HomeNavigation") as? UINavigationController {
//                    self.present(newView, animated: true)
//                }
//            }))
//            present(ac, animated: true)
//        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if navigationController?.visibleViewController?.title == "Department Map" {
            super.viewWillTransition(to: size, with: coordinator)
            self.mapScrollView.zoomScale = CGFloat(1)
            setMapZoom(size: size)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            self.disconnect()
        }
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @IBAction func openDestinationSelection(_ sender: UIButton) {
        if let selectPlace = storyboard?.instantiateViewController(withIdentifier: "SelectPlace") {
            if let selectPlace = selectPlace as? SelectPlaceViewController {
                
                for vertex in allGraph.canvas {
                    if vertex.isPOI {
                        selectPlace.canvas.append(vertex)
                    }
                }
                
                selectPlace.kindOfButton = sender.tag
                selectPlace.delegate = self
                self.navigationController?.pushViewController(selectPlace, animated: true)
            }
        }
    }
    
    @IBAction func startNavigation(_ sender: UIButton) {
        self.imageView.image = originalImage
        lastDirection = ""
        //self.imageView.image = self.drawLines(size: self.imageView.image!.size, image: self.imageView.image!, graph: self.allGraph, color: UIColor.blue)
        flagView?.isHidden = true
        
        if let lastPosition = lastPosition {
            startingVertex = getNearestVertex(position: lastPosition, graph: allGraph)
            if let startingVertex = startingVertex {
                searchBestPath(startingPoint: startingVertex, destinationPoint: destinationVertex!, graph: allGraph)
                
                UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                    self.selectDestinationView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.size.height)
                })
                
                UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                    self.navigationView.transform = CGAffineTransform(translationX: 0, y: 0)
                })
            } else {
                let ac = UIAlertController(title: "Position Error", message: "Error. It is not possible to retrieve your position.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        } else {
            let ac = UIAlertController(title: "Position Error", message: "Error. It is not possible to retrieve your position.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
    }
    
    @IBAction func stopNavigation(_ sender: UIButton) {
        stopNavigation()
    }
    
    func stopNavigation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.navigationView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.size.height)
        })
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.selectDestinationView.transform = CGAffineTransform(translationX: 0, y: 0)
        })
        
        bestGraph = nil
        self.imageView.image = originalImage
        flagView?.isHidden = true
    }
    
    //************************ Inizio funzioni gestione connessione bluetooth ************************ //
    func disconnect() {
        DispatchQueue.global(qos: .userInteractive).async {
            if let arduinoPeripherals = self.arduinoPeripherals {
                if let arduinoCharacteristic = self.arduinoCharacteristic {
                    arduinoPeripherals.setNotifyValue(false, for: arduinoCharacteristic)
                }
                self.centralManager?.cancelPeripheralConnection(arduinoPeripherals)
            }
            self.arduinoCharacteristic = nil
        }
    }
    
    func pauseScan() {
        // Scanning uses up battery on phone, so pause the scan process for the designated interval.
        //print("*** PAUSING SCAN...")
        _ = Timer(timeInterval: timerPauseInterval, target: self, selector: #selector(resumeScan), userInfo: nil, repeats: false)
        centralManager.stopScan()
    }
    
    func resumeScan() {
        if keepScanning {
            // Start scanning again...
            //print("*** RESUMING SCAN!")
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            self.errorMessageLabel.text = "Searching for tags..."
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                self.errorMessageView.alpha = 1
                self.errorMessageLabel.alpha = 1
                self.errorMessageView.isHidden = false
            })
            
            UIView.animate(withDuration: 0.8, delay:0.0, options:[.autoreverse, .repeat], animations: {
                self.errorMessageLabel.alpha = 0
            }, completion: nil)
        }
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var showMessage = true
        var message = ""
        
        switch central.state {
        case .poweredOff:
            message = "Bluetooth on this device is currently powered off."
        case .unsupported:
            message = "This device does not support Bluetooth Low Energy."
        case .unauthorized:
            message = "This app is not authorized to use Bluetooth Low Energy."
        case .resetting:
            message = "The BLE Manager is resetting; a state update is pending."
        case .unknown:
            message = "The state of the BLE Manager is unknown."
        case .poweredOn:
            showMessage = false
            message = "Searching for tags..."
            
            print(message)
            keepScanning = true
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
        
        if showMessage {
            self.errorMessageLabel.text = message
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                self.errorMessageView.isHidden = false
                self.errorMessageView.alpha = 1
                self.errorMessageLabel.alpha = 1
            })
        } else {
            self.errorMessageLabel.text = message
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                self.errorMessageView.alpha = 1
                self.errorMessageLabel.alpha = 1
                self.errorMessageView.isHidden = false
            })
            
            UIView.animate(withDuration: 0.8, delay:0.0, options:[.autoreverse, .repeat], animations: {
                self.errorMessageLabel.alpha = 0
            }, completion: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("NEXT PERIPHERAL NAME: \(peripheralName)")
            print("NEXT PERIPHERAL UUID: \(peripheral.identifier.uuidString)")
            
            if peripheral.identifier.uuidString == identifier! {
                print("SENSOR TAG FOUND! ADDING NOW!!!")
                
                tagName = peripheralName
                
                UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                    self.errorMessageLabel.text = "Sensor tag found. Connecting..."
                    self.errorMessageView.alpha = 1
                    self.errorMessageLabel.alpha = 1
                    self.errorMessageView.isHidden = false
                })
                
                // to save power, stop scanning for other devices
                centralManager.stopScan()
                
                // save a reference to the sensor tag
                arduinoPeripherals = peripheral
                arduinoPeripherals!.delegate = self
                
                // Request a connection to the peripheral
                centralManager.connect(arduinoPeripherals!, options: nil)
            }
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("**** SUCCESSFULLY CONNECTED TO SENSOR TAG!!!")
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            self.errorMessageLabel.text = "Connected to \(self.tagName)"
            self.errorMessageView.alpha = 1
            self.errorMessageLabel.alpha = 1
            self.errorMessageView.isHidden = false
        })
        peripheral.discoverServices(nil)
        
        DispatchQueue.global(qos: .userInitiated).async {
            sleep(5)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                    self.errorMessageView.alpha = 0
                    self.errorMessageLabel.alpha = 0
                    self.errorMessageView.isHidden = true
                })
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("**** CONNECTION TO SENSOR TAG FAILED!!!")
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            self.errorMessageLabel.text = "Connection to sensor tag failed"
            self.errorMessageView.alpha = 1
            self.errorMessageLabel.alpha = 1
            self.errorMessageView.isHidden = false
        })
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("**** DISCONNECTED FROM SENSOR TAG!!!")
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            self.errorMessageLabel.text = "Disconnected from sensor tag"
            self.errorMessageView.alpha = 1
            self.errorMessageLabel.alpha = 1
            self.errorMessageView.isHidden = false
        })
        
        if error != nil {
            print("****** DISCONNECTION DETAILS: \(error!.localizedDescription)")
        }
        arduinoPeripherals = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            sleep(10)
            DispatchQueue.main.async {
                self.centralManager.scanForPeripherals(withServices: nil, options: nil)
                self.initialPacket = true
                self.kalmanFilter = nil
                self.firstPosition = true
                self.errorMessageLabel.text = "Searching for tags..."
                UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                    self.errorMessageView.alpha = 1
                    self.errorMessageLabel.alpha = 1
                    self.errorMessageView.isHidden = false
                })
                
                UIView.animate(withDuration: 0.8, delay:0.0, options:[.autoreverse, .repeat], animations: {
                    self.errorMessageLabel.alpha = 0
                }, completion: nil)
                
                let subViews = self.imageView.subviews
                for subview in subViews{
                    if (subview == self.arrowView) {
                        subview.removeFromSuperview()
                        return
                    }
                }
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING SERVICES: \(String(describing: error?.localizedDescription))")
            return
        }
        
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                print("Discovered service \(service)")
                // If we found either the temperature or the humidity service, discover the characteristics for those services.
                if (service.uuid == CBUUID(string: RBL_SERVICE_UUID)) {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING CHARACTERISTICS: \(String(describing: error?.localizedDescription))")
            return
        }
        
        if let characteristics = service.characteristics {
            
            for characteristic in characteristics {
                // Temperature Data Characteristic
                if characteristic.uuid == CBUUID(string: RBL_CHAR_TX_UUID) {
                    // Enable the IR Temperature Sensor notifications
                    arduinoCharacteristic = characteristic
                    arduinoPeripherals?.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let dataBytes = characteristic.value {
            if characteristic.uuid == CBUUID(string: RBL_CHAR_TX_UUID) {
                
                if error != nil {
                    print("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(String(describing: error?.localizedDescription))")
                    return
                }
                
                let array = [UInt8](dataBytes)
                let lastPacket = String(bytes: array, encoding: String.Encoding.utf8)!
                
                if lastPacket.contains("R") && initialPacket {
                    lastString = lastPacket.replacingOccurrences(of: "R", with: "")
                    initialPacket = false
                } else if lastPacket.contains("R") && !initialPacket {
                    var separateValues = lastString.components(separatedBy: ",")
                    if separateValues.count == 6 {
                        if kalmanFilter == nil {
                            kalmanFilter = KalmanFilter()
                        }
                        print("NUOVO PACCHETTO")
                        for i in 0..<separateValues.count {
                            separateValues[i] = separateValues[i].replacingOccurrences(of: "\0", with: "")
                        }
                        let x: CGFloat = CGFloat((separateValues[1] as NSString).doubleValue)
                        let y: CGFloat = CGFloat((separateValues[2] as NSString).doubleValue)
                        let accX: CGFloat = CGFloat((separateValues[3] as NSString).doubleValue)
                        let accY: CGFloat = CGFloat((separateValues[4] as NSString).doubleValue)
                        let heading: CGFloat = CGFloat((separateValues[5] as NSString).doubleValue)
                        var position = kalmanFilter?.kalman_filter(coordX: Int(x), coordY: Int(y), accX: Float(accX)/100.00, accY: Float(accY)/100.00)
                        
                        if (position?.x)! < 0 {
                            position?.x = 0
                        } else if (position?.x)! > Int(realRoomWidth) {
                            position?.x = Int(realRoomWidth)
                        }
                        if (position?.y)! < 0 {
                            position?.y = 0
                        } else if (position?.y)! > Int(realRoomHeight) {
                            position?.y = Int(realRoomHeight)
                        }
                        
                        if let bestGraph = bestGraph {
                            navigation(position: normalizePosition(meterX: CGFloat((position?.x)!), meterY: CGFloat((position?.y)!)), heading: heading, graph: bestGraph)
                        } else {
                            let newPosition = normalizePosition(meterX: CGFloat((position?.x)!), meterY: CGFloat((position?.y)!))
                            updateMap(x: newPosition.x, y: newPosition.y, heading: CGFloat(180)+heading+CGFloat(0)) //85 è lo sfasamento del nostro sistema di riferiemnto verso il nord. divido per 100 l'accelerazione per trasformare da mG a m/s^2
                        }
                    }
                    lastString = lastPacket.replacingOccurrences(of: "R", with: "")
                } else if !lastPacket.contains("R") && !initialPacket {
                    lastString.append(lastPacket.replacingOccurrences(of: "\n", with: ""))
                }
            }
        }
    }
    
}

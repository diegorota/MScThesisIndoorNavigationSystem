//
//  MapViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 23/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit
import CoreBluetooth

class DepartmentMapViewController: UIViewController, UIScrollViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, SelectPlaceViewControllerDelegate {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var mapScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var errorMessageView: UIView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var selectDestinationView: SelectDestinationView!
    
    // View della freccia
    var arrowView: UIView!
    
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
    var lastPosition: CGPoint?
    var lastHeading: CGFloat?
    var firstPosition = true
    
    // Variabile filtro di Kalman
    var kalmanFilter: KalmanFilter?
    
    // Variabile grafo
    var allGraph: Graph!
    var bestGraph: Graph?
    var maximumDistance: CGFloat!
    var startingVertex: Vertex?
    var destinationVertex: Vertex?
    var originalImage: UIImage!
    
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
        
        // Setto view navigation
        selectDestinationView.backgroundColor = Colors.mediumColor
        selectDestinationView.startingButton.tintColor = Colors.darkColor
        selectDestinationView.destinationButton.tintColor = Colors.darkColor
        selectDestinationView.navigateButton.isEnabled = false
        
        maximumDistance = 1000*(imageView.image?.size.width)!/realRoomWidth
        print("maximum distance: \(maximumDistance)")
        
        self.allGraph = self.initializeGraph()
        originalImage = self.imageView.image!
        self.imageView.image = self.drawLines(size: self.imageView.image!.size, image: self.imageView.image!, graph: self.allGraph, color: UIColor.blue)
        
        // let kalmanPosition = CGPoint(x: 6000, y: 6500)
        // let kalmanPositionPixel = normalizePosition(meterX: kalmanPosition.x, meterY: kalmanPosition.y)
        // updateMap(x: kalmanPosition.x, y: kalmanPosition.y, heading: 90)
        // var lessDistance: CGFloat? = nil
        // var nearestVertex: Vertex? = nil
        
//        for v in (bestGraph?.canvas)! {
//            let distance = CGPointDistance(from: kalmanPositionPixel, to: v.position)
//            print(distance)
//            if lessDistance == nil {
//                if distance < maximumDistance {
//                    lessDistance = distance
//                    nearestVertex = v
//                }
//            } else {
//                if distance < lessDistance! && distance < maximumDistance {
//                    lessDistance = distance
//                    nearestVertex = v
//                }
//            }
//        }
//        
//        if let nearestVertex = nearestVertex {
//            print("il nodo più vicino è \(nearestVertex.key!). Indicazione: \(nearestVertex.neighbors[0].direction)")
//        } else {
//            print("sei lontano dal percorso ottimale. Ricalcolo percorso.")
//        }
        
        
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
        }
    }
    
    func initializeGraph() -> Graph {
        let graph = Graph()
        
        let g1 = graph.addVertex(key: "Baresi", position: CGPoint(x: 123, y: 352))
        let g2 = graph.addVertex(key: "Lab 1", position: CGPoint(x: 123, y: 336))
        let g3 = graph.addVertex(key: "Svincolo Sam", position: CGPoint(x: 131, y: 134))
        let g4 = graph.addVertex(key: "Svincolo Pradella", position: CGPoint(x: 247, y: 137))
        let g5 = graph.addVertex(key: "Lab 2", position: CGPoint(x: 247, y: 222))
        let g6 = graph.addVertex(key: "Svincolo bagno ragazze", position: CGPoint(x: 246, y: 406))
        let g7 = graph.addVertex(key: "Svincolo Ardagna", position: CGPoint(x: 130, y: 422))
        let g8 = graph.addVertex(key: "Tesisti", position: CGPoint(x: 186, y: 286))
        
        graph.addEdge(source: g1, neighbor: g2, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g2, neighbor: g1, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g2, neighbor: g3, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g3, neighbor: g2, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g3, neighbor: g4, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g4, neighbor: g3, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g4, neighbor: g5, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g5, neighbor: g4, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g5, neighbor: g6, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g6, neighbor: g5, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g6, neighbor: g7, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g7, neighbor: g6, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g7, neighbor: g1, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g1, neighbor: g7, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g2, neighbor: g8, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g8, neighbor: g2, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g8, neighbor: g5, weight: 1, direction: Direction.straight.rawValue)
        graph.addEdge(source: g5, neighbor: g8, weight: 1, direction: Direction.straight.rawValue)
        
        return graph
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y);
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to));
    }
    
    func placeViewControllerDidSelect(value: Vertex?, kindOfButton: Int) {
        if kindOfButton == 0 {
            startingVertex = value
            if let value = value {
                selectDestinationView.startingButton.setTitle(value.key, for: .normal)
            } else  {
                selectDestinationView.startingButton.setTitle("Starting Point", for: .normal)
            }
        } else if kindOfButton == 1 {
            destinationVertex = value
            if let value = value {
                selectDestinationView.destinationButton.setTitle(value.key, for: .normal)
            } else {
                selectDestinationView.destinationButton.setTitle("Destination Point", for: .normal)
            }
        }
        
        if let _ = startingVertex {
            if let _ = destinationVertex {
                selectDestinationView.navigateButton.isEnabled = true
            } else {
                selectDestinationView.navigateButton.isEnabled = false
            }
        } else {
            selectDestinationView.navigateButton.isEnabled = false
        }
    }
    
    func updateMap(x: CGFloat, y: CGFloat, heading: CGFloat) {
        lastPosition = normalizePosition(meterX: x, meterY: y)
        
        lastHeading = heading
        
        if firstPosition {
            addArrowToMap()
            arrowView.center = lastPosition!
            arrowView.transform = CGAffineTransform(rotationAngle: lastHeading!)
            firstPosition = false
        } else {
            UIView.animate(withDuration: 0.05, delay: 0, options: [], animations: {
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
        self.disconnect()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @IBAction func openDestinationSelection(_ sender: UIButton) {
        if let selectPlace = storyboard?.instantiateViewController(withIdentifier: "SelectPlace") {
            if let selectPlace = selectPlace as? SelectPlaceViewController {
                selectPlace.canvas = allGraph.canvas
                selectPlace.kindOfButton = sender.tag
                selectPlace.delegate = self
                self.navigationController?.pushViewController(selectPlace, animated: true)
            }
        }
    }
    
    @IBAction func startNavigation(_ sender: UIButton) {
        self.imageView.image = originalImage
        
        self.imageView.image = self.drawLines(size: self.imageView.image!.size, image: self.imageView.image!, graph: self.allGraph, color: UIColor.blue)
        if let a = startingVertex {
            print(a.key!)
        }
        if let b = destinationVertex {
            print(b.key!)
        }
        searchBestPath(startingPoint: startingVertex!, destinationPoint: destinationVertex!, graph: allGraph)
    }
    
    //************************ Inizio funzioni gestione connessione bluetooth ************************ //
    func disconnect() {
        if let arduinoPeripherals = self.arduinoPeripherals {
            if let arduinoCharacteristic = self.arduinoCharacteristic {
                arduinoPeripherals.setNotifyValue(false, for: arduinoCharacteristic)
            }
            centralManager?.cancelPeripheralConnection(arduinoPeripherals)
        }
        arduinoCharacteristic = nil
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
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        initialPacket = true
        kalmanFilter = nil
        firstPosition = true
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
            if (subview == arrowView) {
                subview.removeFromSuperview()
                return
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
                        
                        updateMap(x: CGFloat(position!.x), y: CGFloat(position!.y), heading: CGFloat(180)+heading+CGFloat(85+90)) //85 è lo sfasamento del nostro sistema di riferiemnto verso il nord. divido per 100 l'accelerazione per trasformare da mG a m/s^2                       }
                        
                    }
                    lastString = lastPacket.replacingOccurrences(of: "R", with: "")
                } else if !lastPacket.contains("R") && !initialPacket {
                    lastString.append(lastPacket.replacingOccurrences(of: "\n", with: ""))
                }
            }
        }
    }
    
}

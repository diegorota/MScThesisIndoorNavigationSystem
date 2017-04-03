//
//  MapViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 23/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit
import CoreBluetooth

class MapViewController: UIViewController, UIScrollViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    // View della freccia
    var arrowView: UIView!
    
    // Variabili necessarie per la gestione del bluetooth
    var centralManager:CBCentralManager!
    var arduinoPeripherals:CBPeripheral?
    var arduinoCharacteristic:CBCharacteristic?
    
    let identifier = "3CF2AC85-97E2-4346-8A4B-DE1398DB9B37"
    let RBL_SERVICE_UUID = "713D0000-503E-4C75-BA94-3148F18D941E"
    let RBL_CHAR_TX_UUID = "713D0002-503E-4C75-BA94-3148F18D941E"
    let RBL_CHAR_RX_UUID = "713D0003-503E-4C75-BA94-3148F18D941E"
    
    var lastString = ""
    var initialPacket = true
    
    let timerPauseInterval:TimeInterval = 10.0
    let timerScanInterval:TimeInterval = 2.0
    var keepScanning = false
    
    // Variabili necessarie per zoom e posizione freccia su mappa
    var minZoom: Double!
    var maxZoom: Double!
    let realRoomWidth:CGFloat = 4170
    let realRoomHeight:CGFloat = 4650
    var imageWidth: CGFloat!
    var imageHeight: CGFloat!
    var lastPosition: CGPoint?
    var lastHeading: CGFloat?
    var firstPosition = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Memorizzo altezza e larghezza dell'immagine. Verranno usate per le proporzioni dello zoom della mappa
        imageWidth = imageView.frame.width
        imageHeight = imageView.frame.height
        
        // Chiamo la funzione per adattare lo zoom della mappa alla larghezza del display
        setMapZoom(size: view.frame.size)
        
        // Setto riconoscimento doppio tocco per effettuare zoom
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoom))
        tap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(tap)

    }
    
    func updateMap(x: CGFloat, y: CGFloat, heading: CGFloat) {
        lastPosition = normalizePosition(meterX: x, meterY: y)
        var deltaHeading: CGFloat
        
        if let lastHeading = lastHeading {
            deltaHeading = heading - lastHeading
        } else {
            deltaHeading = 0
        }
        lastHeading = heading
        
        if firstPosition {
            addArrowToMap()
            arrowView.center = lastPosition!
            arrowView.transform = CGAffineTransform(rotationAngle: lastHeading!)
            firstPosition = false
        } else {
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                //self.arrowView.transform = CGAffineTransform(translationX: self.lastPosition!.x, y: self.lastPosition!.y)
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
    
    // Funzione chiamata quando si effettua un dippio tocco sulla mappa. Gestisce lo zoom.
    func zoom(sender: UIGestureRecognizer) {
        if (scrollView.zoomScale < 1.5) {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
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
        self.scrollView.minimumZoomScale = CGFloat(minZoom)
        self.scrollView.maximumZoomScale = CGFloat(maxZoom)
        self.scrollView.zoomScale = CGFloat(minZoom)
    }

    // Funzione che centra la mappa nel punto in cui si trova l'utente.
    @IBAction func centerView(_ sender: UIButton) {
        self.scrollView.zoom(to: CGRect(origin: CGPoint(x:(lastPosition?.x)!-50,y:(lastPosition?.y)!-50), size: CGSize(width: 100, height: 100)), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Map"
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.scrollView.zoomScale = CGFloat(1)
        setMapZoom(size: size)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disconnect()
    }
    
    //Inizio funzioni gestione connessione bluetooth
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
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var showAlert = true
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
            showAlert = false
            message = "Bluetooth LE is turned on and ready for communication."
            
            print(message)
            keepScanning = true
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
        
        if showAlert {
            let alertController = UIAlertController(title: "Central Manager State", message: message, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print("centralManager didDiscoverPeripheral - CBAdvertisementDataLocalNameKey is \"\(CBAdvertisementDataLocalNameKey)\"")
        
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("NEXT PERIPHERAL NAME: \(peripheralName)")
            print("NEXT PERIPHERAL UUID: \(peripheral.identifier.uuidString)")
            
            if peripheral.identifier.uuidString == identifier {
                print("SENSOR TAG FOUND! ADDING NOW!!!")
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
        
        // Now that we've successfully connected to the SensorTag, let's discover the services.
        // - NOTE:  we pass nil here to request ALL services be discovered.
        //          If there was a subset of services we were interested in, we could pass the UUIDs here.
        //          Doing so saves battery life and saves time.
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("**** CONNECTION TO SENSOR TAG FAILED!!!")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("**** DISCONNECTED FROM SENSOR TAG!!!")
        if error != nil {
            print("****** DISCONNECTION DETAILS: \(error!.localizedDescription)")
        }
        arduinoPeripherals = nil
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        initialPacket = true
        
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
                
                if lastPacket.contains("?") && initialPacket {
                    lastString = lastPacket.replacingOccurrences(of: "?", with: "")
                    initialPacket = false
                } else if lastPacket.contains("?") && !initialPacket {
                    let separateValues = lastString.components(separatedBy: ",")
                    if separateValues.count == 4 {
                        print("NUOVO PACCHETTO")
                        if let x: CGFloat = CGFloat((separateValues[1] as NSString).doubleValue) {
                            if let y: CGFloat = CGFloat((separateValues[2] as NSString).doubleValue) {
                                if let heading: CGFloat = CGFloat((separateValues[3] as NSString).doubleValue) {
                                    updateMap(x: x, y: y, heading: CGFloat(180)+heading+CGFloat(85)) //85 è lo sfasamento del nostro sistema di riferiemnto verso il nord
                                } else {
                                    print("Packet error!")
                                }
                            } else {
                                print("Packet error!")
                            }
                        } else {
                            print("Packet error!")
                        }
                    }
                    lastString = lastPacket.replacingOccurrences(of: "?", with: "")
                } else if !lastPacket.contains("?") && !initialPacket {
                    lastString.append(lastPacket.replacingOccurrences(of: "\n", with: ""))
                }
            }
        }
    }
    
}

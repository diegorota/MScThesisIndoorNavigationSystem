//
//  PairingViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 22/04/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit
import CoreBluetooth

class PairingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var pairingTableView: UITableView!
    var bluetoothDevices = [BluetoothDevice]()
    var selectedDevice: String?
    
    // Variabili necessarie per la gestione del bluetooth
    var centralManager:CBCentralManager!
    let timerPauseInterval:TimeInterval = 10.0
    let timerScanInterval:TimeInterval = 2.0
    var keepScanning = false
    var hourTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pairing"
        
        pairingTableView.delegate = self
        pairingTableView.dataSource = self
        pairingTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        centralManager = CBCentralManager(delegate: self, queue: nil)

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfSections: Int = 0
        if bluetoothDevices.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = bluetoothDevices.count
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "Searching for devices..."
            noDataLabel.textColor     = UIColor.white
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont.systemFont(ofSize: 28)
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothCell", for: indexPath)
        cell.textLabel?.text = bluetoothDevices[indexPath.row].name
        cell.textLabel?.textColor = Colors.darkColor
        cell.detailTextLabel?.text = bluetoothDevices[indexPath.row].uuid
        cell.detailTextLabel?.textColor = Colors.darkColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDevice = bluetoothDevices[indexPath.row].uuid
        defaults.set(selectedDevice!, forKey: UserDefaultsKeys.uuidDeviceKey)
        tableView.deselectRow(at: indexPath, animated: true)
        
        let ac = UIAlertController(title: "Done!", message: "You have selected the devices. Now you can open the map.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Go Home", style: .default, handler: goHome))
        present(ac, animated: true)
    }
    
    func goBack(_ sender: UIAlertAction) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func goHome(_ sender: UIAlertAction) {
        if let newView = self.storyboard?.instantiateViewController(withIdentifier: "HomeNavigation") as? UINavigationController {
            present(newView, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hourTimer == nil {
            hourTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(refreshBluetoothDevices), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        centralManager = CBCentralManager()
        if hourTimer != nil {
            hourTimer?.invalidate()
            hourTimer = nil
        }
    }
    
    // Inizio funzioni gestione Bluetooth
    func pauseScan() {
        // Scanning uses up battery on phone, so pause the scan process for the designated interval.
        //print("*** PAUSING SCAN...")
        _ = Timer.scheduledTimer(timeInterval: timerPauseInterval, target: self, selector: #selector(resumeScan), userInfo: nil, repeats: false)
        centralManager.stopScan()
    }
    
    func resumeScan() {
        if keepScanning {
            // Start scanning again...
            //print("*** RESUMING SCAN!")
            _ = Timer.scheduledTimer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func refreshBluetoothDevices() {
        print("REFRESH")
        bluetoothDevices.removeAll()
        pairingTableView.reloadData()
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
            _ = Timer.scheduledTimer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
        
        if showMessage {
            let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default))
            present(ac, animated: true)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("NEXT PERIPHERAL NAME: \(peripheralName)")
            print("NEXT PERIPHERAL UUID: \(peripheral.identifier.uuidString)")
            
            var discovered = false
            for device in bluetoothDevices {
                if device.uuid == peripheral.identifier.uuidString {
                    discovered = true
                }
            }
            if !discovered {
                bluetoothDevices.append(BluetoothDevice(name: peripheralName, uuid: peripheral.identifier.uuidString))
                pairingTableView.reloadData()
            }
        }
        
    }

}

//
//  ExaminationDetailViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 20/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit
import CoreLocation

class ExaminationDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let defaults = UserDefaults.standard
    
    var upperExaminationDetail = [Information]()
    var bottomExaminationDetail = [Information]()
    var examinationDescriptionText = String()
    var checkinDone = false
    var POICoordinates: CGPoint? = nil
    
    var queueLabel: String?
    var waitingLabel: String?
    var ticketLabel: String?
    
    var isToday = false
    
    var locationManager: CLLocationManager!
    var beaconuuid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

    }
    
    // Ritorno 8, che è il numero di elementi che devono essere visualizzati nella pagina
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    // Funzione che crea a runtime il contenuto delle celle della colle tion view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            var reusableIdentifier: String!
            
            if checkinDone {
                reusableIdentifier = "MedicalExaminationCheckinOKCell"
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableIdentifier, for: indexPath) as! MedicalExaminationCheckinOKCell
                
                if queueLabel == nil || ticketLabel == nil || waitingLabel == nil {
                    self.loadCheckinDetails()
                }
                cell.checkinImage.image = UIImage(named: "check")
                cell.ticketImage.image = UIImage(named: "ticket")?.withRenderingMode(.alwaysTemplate)
                cell.ticketImage.tintColor = Colors.darkColor
                cell.queueImage.image = UIImage(named: "queue")?.withRenderingMode(.alwaysTemplate)
                cell.queueImage.tintColor = Colors.darkColor
                cell.waitingImage.image = UIImage(named: "waiting")?.withRenderingMode(.alwaysTemplate)
                cell.waitingImage.tintColor = Colors.darkColor
                cell.ticketLabel.text = ticketLabel!
                cell.ticketLabel.textColor = Colors.darkColor
                cell.queueLabel.text = queueLabel!
                cell.queueLabel.textColor = Colors.darkColor
                cell.waitingLabel.text = waitingLabel!
                cell.waitingLabel.textColor = Colors.darkColor
                cell.queueLabel.adjustsFontSizeToFitWidth = true
                cell.waitingLabel.adjustsFontSizeToFitWidth = true
                cell.ticketLabel.adjustsFontSizeToFitWidth = true
                cell.layer.backgroundColor = UIColor(white: 1, alpha: 0.70).cgColor
                return cell
            } else {
                reusableIdentifier = "MedicalExaminationCheckinKOCell"
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableIdentifier, for: indexPath) as! MedicalExaminationCheckinKOCell
                cell.checkinImage.image = UIImage(named: "totem")
                cell.textView.textColor = Colors.darkColor
                cell.layer.backgroundColor = UIColor(white: 1, alpha: 0.70).cgColor
                if !isToday {
                    cell.textView.text = "The day of the visit you can check-in simply putting your smartphone near the totem."
                }
                return cell
            }
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationInformationCell", for: indexPath) as! MedicalExaminationInformationCell
            cell.titleLabel.text = upperExaminationDetail[0].title
            cell.informationLabel.text = upperExaminationDetail[0].information
            cell.titleLabel.textColor = Colors.darkColor
            cell.informationLabel.textColor = Colors.darkColor
            cell.layer.backgroundColor = UIColor(white: 1, alpha: 0.70).cgColor
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationInformationCell", for: indexPath) as! MedicalExaminationInformationCell
            cell.titleLabel.text = upperExaminationDetail[1].title
            cell.informationLabel.text = upperExaminationDetail[1].information
            cell.titleLabel.textColor = Colors.darkColor
            cell.informationLabel.textColor = Colors.darkColor
            cell.layer.backgroundColor = UIColor(white: 1, alpha: 0.70).cgColor
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationInformationCell", for: indexPath) as! MedicalExaminationInformationCell
            cell.titleLabel.text = upperExaminationDetail[2].title
            cell.informationLabel.text = upperExaminationDetail[2].information
            cell.titleLabel.textColor = Colors.darkColor
            cell.informationLabel.textColor = Colors.darkColor
            cell.layer.backgroundColor = UIColor(white: 1, alpha: 0.70).cgColor
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationInformationCell", for: indexPath) as! MedicalExaminationInformationCell
            cell.titleLabel.text = bottomExaminationDetail[0].title
            cell.informationLabel.text = bottomExaminationDetail[0].information
            cell.titleLabel.textColor = Colors.darkColor
            cell.informationLabel.textColor = Colors.darkColor
            cell.layer.backgroundColor = UIColor(white: 1, alpha: 0.70).cgColor
            return cell
        case 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationButtonCell", for: indexPath) as! MedicalExaminationButtonCell
            cell.button.layer.backgroundColor = Colors.mediumColor.cgColor
            cell.button.setImage(UIImage(named: "pin")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
            cell.button.tintColor = UIColor.white
            return cell
        case 6:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationDescriptionCell", for: indexPath) as! MedicalExaminationDescriptionCell
            cell.descriptionTextView.text = examinationDescriptionText
            cell.descriptionTextView.textColor = Colors.darkColor
            cell.layer.backgroundColor = UIColor(white: 1, alpha: 0.70).cgColor
            return cell
        case 7:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationInformationCell", for: indexPath) as! MedicalExaminationInformationCell
            cell.titleLabel.text = bottomExaminationDetail[1].title
            cell.informationLabel.text = bottomExaminationDetail[1].information
            cell.titleLabel.textColor = Colors.darkColor
            cell.informationLabel.textColor = Colors.darkColor
            cell.layer.backgroundColor = UIColor(white: 1, alpha: 0.70).cgColor
            return cell
        default:
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    // Funzione che setta a runtime le dimensioni delle celle
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxHeight: CGFloat = 144
        let mediumHeight: CGFloat = 44
        let littleHeight: CGFloat = 40
        var width: CGFloat
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            width = view.bounds.size.width-40
        case .pad:
            width = view.bounds.size.width-40
        default:
            width = view.bounds.size.width-40
        }
        
        switch indexPath.item {
        case 0:
            return CGSize(width: width, height: maxHeight)
        case 1:
            return CGSize(width: width, height: mediumHeight)
        case 2:
            return CGSize(width: width, height: mediumHeight)
        case 3:
            return CGSize(width: width, height: mediumHeight)
        case 4:
            return CGSize(width: width, height: mediumHeight)
        case 5:
            return CGSize(width: width, height: mediumHeight)
        case 6:
            let attributedString = NSAttributedString(string: examinationDescriptionText, attributes: [NSFontAttributeName : UIFont(name: "Helvetica", size: 16)!])
            let boundingRect = attributedString.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            return CGSize(width: boundingRect.width, height: boundingRect.height)
        case 7:
            return CGSize(width: width, height: littleHeight)
        default:
            return CGSize(width: width, height: littleHeight)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Details"
        checkinDone = defaults.bool(forKey: UserDefaultsKeys.checkinDoneKey)
    }
    
    // Funzione che ridimensiona le celle quando si ruota lo schermo
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
    
    
    @IBAction func navigate(_ sender: Any) {
        if let map = storyboard?.instantiateViewController(withIdentifier: "MedicalCenterMap") as? MedicalCenterMapViewController {
            if let coordinates = POICoordinates {
                map.POIPosition = coordinates
                self.navigationController?.pushViewController(map, animated: true)
            }
        }
    }
    
    // Funzione che scarica il file JSON dal server
    func loadCheckinDetails() {
        if checkinDone {
            if let path = Bundle.main.path(forResource: "json/checkin", ofType: "json") {
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) {
                    let json = JSON(data: data)
                    parse(json: json)
                }
            }
        }
    }
    
    // Funzione che parsa e salva il contenuto del file JSON
    func parse(json: JSON) {
        queueLabel = "Queue: \(json["queue"])"
        waitingLabel = "Waiting time: \(json["waiting_time"])min"
        ticketLabel = "Your ticket: \(json["ticket"])"
    }
    
    
    // Inizio funzioni utili per la gestione del beacon
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    if !checkinDone && isToday {
                        startScanning()
                    }
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: beaconuuid)!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "MyBeacon")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    func stopScanning() {
        let uuid = UUID(uuidString: beaconuuid)!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "MyBeacon")
        
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            for beacon in beacons {
                if beacon.proximityUUID.uuidString == beaconuuid && beacon.proximity == CLProximity.immediate {
                    stopScanning()
                    let ac = UIAlertController(title: "Checkin", message: "Would you like to check-in?", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ckeck-in", style: .default, handler: reloadCheckin))
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: restartScaninng))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    func restartScaninng(_ sender: UIAlertAction) {
        startScanning()
    }
    
    func reloadCheckin(_ sender: UIAlertAction) {
        stopScanning()
        checkinDone = true
        defaults.setValue(checkinDone, forKey: UserDefaultsKeys.checkinDoneKey)
        collectionView.reloadData()
    }
    
}

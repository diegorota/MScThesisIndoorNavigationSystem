//
//  HomeViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 15/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit
import UserNotifications

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var collectionView: UICollectionView!
    
    var tiles = [HomeButton]()
    var hourTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        title = "Medical Center"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Settings"), style: .plain, target: self, action: #selector(openSettings))
        loadTiles()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: { (granted,error) in
                self.defaults.set(granted, forKey: UserDefaultsKeys.localnotificationsEnabledKey)
        })
        
        // Creazione notifiche per Medical Examination e Prescriptions
        DispatchQueue.global(qos: .userInitiated).async {
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            let examinations = MedicalExaminationSectionData.getData(refreshData: false)
            let prescriprions = PrescriptionSectionData.getData(refreshData: false)
            
            for i in 0...1 {
                for examination in examinations[i].items as! [ExaminationDetail] {
                    
                    let time = examination.hour.components(separatedBy: ":")
                    let date = examination.date.components(separatedBy: "-")
                    
                    if let year: Int = Int(date[0]) {
                        if let month: Int = Int(date[1]) {
                            if let day: Int = Int(date[2]) {
                                if let hour: Int = Int(time[0]) {
                                    if let minutes: Int = Int(time[1]) {
                                        let content = UNMutableNotificationContent()
                                        content.title = "You have a new Medical Examination"
                                        content.body = "\(examination.name) Medical Examination will start at \(hour):\(time[1])."
                                        content.categoryIdentifier = "message"
                                        
                                        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(year: year, month: month, day: day, hour: hour-1, minute: minutes), repeats: false)
                                        let request = UNNotificationRequest(identifier: "\(examination.date)-\(examination.hour)-\(examination.name)", content: content, trigger: trigger)
                                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                                    }
                                }
                            }
                        }
                    }
                }
                
                for prescription in prescriprions[i].items as! [Prescription] {
                    
                    let time = prescription.hour.components(separatedBy: ":")
                    let date = prescription.date.components(separatedBy: "-")
                    
                    if let year: Int = Int(date[0]) {
                        if let month: Int = Int(date[1]) {
                            if let day: Int = Int(date[2]) {
                                if let hour: Int = Int(time[0]) {
                                    if let minutes: Int = Int(time[1]) {
                                        let content = UNMutableNotificationContent()
                                        content.title = "You have a new Prescription"
                                        content.body = "You have to take \(prescription.name) at \(hour):\(time[1])."
                                        content.categoryIdentifier = "message"
                                        
                                        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(year: year, month: month, day: day, hour: hour, minute: minutes), repeats: false)
                                        let request = UNNotificationRequest(identifier: "\(prescription.date)-\(prescription.hour)-\(prescription.name)", content: content, trigger: trigger)
                                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            
        }
    }
    
    func updateHour() {
        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? HomeInfoCell {
            cell.hourLabel.text = composeHour()
        }
    }
    
    func composeDate() -> String {
        
        let date = Date()
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        return "\(day) \(monthConverter(month)) \(year)"
    }
    
    func composeHour() -> String {
        
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        var minuteString: String
        
        if minutes < 10 {
            minuteString = "0\(minutes)"
        } else {
            minuteString = "\(minutes)"
        }
        
        return "\(hour):\(minuteString)"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiles.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeInfoCell", for: indexPath) as! HomeInfoCell
            cell.helloLabel.text = "Hi, \(defaults.string(forKey: UserDefaultsKeys.nameKey)!)"
            cell.dateLabel.text = composeDate()
            cell.hourLabel.text = composeHour()
            cell.helloLabel.textColor = Colors.darkColor
            cell.hourLabel.textColor = Colors.darkColor
            cell.dateLabel.textColor = Colors.darkColor
            cell.layer.backgroundColor = UIColor(white: 1, alpha: 0.70).cgColor
            cell.layoutIfNeeded()
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeButtonCell", for: indexPath) as! HomeButtonCell
            cell.titleLabel.text = tiles[indexPath.item-1].titleTile.uppercased()
            cell.titleLabel.textColor = Colors.darkColor
            cell.titleLabel.underlined()
            cell.descriptionLabel.text = tiles[indexPath.item-1].descriptionTile
            cell.descriptionLabel.textColor = Colors.darkColor
            cell.iconImage.image = UIImage(named: tiles[indexPath.item-1].logoTile)?.withRenderingMode(.alwaysTemplate)
            cell.iconImage.tintColor = Colors.darkColor
            cell.layer.backgroundColor = UIColor(white: 1, alpha: 0.70).cgColor
            
            DispatchQueue.global(qos: .userInitiated).async {
                var description = ""
                var color = Colors.darkColor
                var seeBadge = false
                var badgeText = ""
                switch indexPath.item {
                case 1:
                    let menu = CafeteriaData.getData()
                    if menu.newMenu! || (!menu.newMenu! && !self.defaults.bool(forKey: UserDefaultsKeys.confirmationMenuBoolKey)){
                        description = "You haven't chosen your menu"
                        color = Colors.green
                        badgeText = "!"
                        seeBadge = true
                        
                    } else {
                        description = "You have already choosen your menu"
                    }
                case 2:
                    let examinations = MedicalExaminationSectionData.getData(refreshData: true)
                    if examinations[0].items.count == 0 {
                        description = "You haven't examinations today"
                    } else if examinations[0].items.count == 1 {
                        description = "You have 1 examination today"
                        badgeText = "1"
                        seeBadge = true
                        color = Colors.green
                    } else {
                        description = "You have \(examinations[0].items.count) examinations today"
                        badgeText = "\(examinations[0].items.count)"
                        seeBadge = true
                        color = Colors.green
                    }
                case 3:
                    description = "Search the hospital places."
                case 4:
                    let prescription = PrescriptionSectionData.getData(refreshData: true)
                    if prescription[0].items.count == 0 {
                        description = "You haven't prescriptions for today"
                    } else {
                        description = "See your prescriptions for today"
                        badgeText = "\(prescription[0].items.count)"
                        seeBadge = true
                        color = Colors.green
                    }
                case 5:
                    description = "See where you are in the hospital"
                case 6:
                    description = "Read the last news of the hospital"
                default:
                    print("Error loading description tile")
                }
                DispatchQueue.main.async {
                    cell.descriptionLabel.text = description
                    cell.descriptionLabel.textColor = color
                    
                    if seeBadge {
                        cell.badge.image = UIImage(named: "badge")?.withRenderingMode(.alwaysTemplate)
                        cell.badge.tintColor = Colors.green
                        cell.badgeNumber.text = badgeText
                    }
                    cell.badgeNumber.isHidden = !seeBadge
                    cell.badge.isHidden = !seeBadge
                }
            }
            
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            return
        }
        UIView.animate(withDuration: 0.15, delay: 0, options: [], animations: {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { [unowned self] (finished: Bool) in
            if indexPath.item != self.tiles.count && indexPath.item != 5 {
                if let newView = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as? UITabBarController {
                    newView.selectedIndex = indexPath.row-1
                    self.navigationController?.pushViewController(newView, animated: true)
                }
            } else if indexPath.item == 5 {
                if let map = self.storyboard?.instantiateViewController(withIdentifier: "DepartmentMap") {
                    self.navigationController?.pushViewController(map, animated: true)
                }
            } else {
                if let newView = self.storyboard?.instantiateViewController(withIdentifier: "News") as? NewsViewController {
                    self.navigationController?.pushViewController(newView, animated: true)
                }
            }
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.transform = CGAffineTransform.identity
        }

    }
    
    // Funzione che setta a runtime le dimensioni delle celle
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 120
        var width: CGFloat
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if indexPath.item == 0 {
                width = view.bounds.size.width
            } else {
                width = view.bounds.size.width/2-3
            }
        case .pad:
            if indexPath.item == 0 {
                width = view.bounds.size.width/3*2-3
            } else {
                width = view.bounds.size.width/3-4
            }
        default:
            if indexPath.item == 0 {
                width = view.bounds.size.width
            } else {
                width = view.bounds.size.width/2-3
            }
        }
        
        return CGSize(width: width, height: height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }
    
    func monthConverter(_ monthNumber: Int) -> String {
        switch monthNumber {
        case 01:
            return "January"
        case 02:
            return "February"
        case 03:
            return "March"
        case 04:
            return "April"
        case 05:
            return "May"
        case 06:
            return "June"
        case 07:
            return "July"
        case 08:
            return "August"
        case 09:
            return "September"
        case 10:
            return "October"
        case 11:
            return "November"
        case 12:
            return "December"
        default:
            print("missing month!")
            return "error"
        }
    }
    
    func openSettings() {
        if let settings = storyboard?.instantiateViewController(withIdentifier: "Settings") as? SettingsViewController {
            navigationController?.pushViewController(settings, animated: true)
        }
    }
    
    // Funzione che carica il file JSON contenente le informazioni delle tiles, crea un oggetto HomeTile per ogni tile e lo inserisce nell'array tiles.
    func loadTiles() {
        
        if let path = Bundle.main.path(forResource: "json/homepage", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) {
                let json = JSON(data: data)
                parse(json: json)
            }
        }
    }
    
    func parse(json: JSON) {
        for tile in json.arrayValue {
            let homeTile = HomeButton(titleTile: tile["tilename"].stringValue, descriptionTile: "Questa è una descrizione.", logoTile: tile["logo"].stringValue, dimensionTile: tile["dimension"].intValue)
            tiles.append(homeTile)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        if hourTimer == nil {
            hourTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateHour), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if hourTimer != nil {
            hourTimer?.invalidate()
            hourTimer = nil
        }
    }
    
}

extension UILabel {
    
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = Colors.darkColor.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

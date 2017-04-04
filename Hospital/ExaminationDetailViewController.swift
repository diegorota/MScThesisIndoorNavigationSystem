//
//  ExaminationDetailViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 20/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class ExaminationDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var upperExaminationDetail = [Information]()
    var bottomExaminationDetail = [Information]()
    var examinationDescriptionText = String()
    var checkinDone = false
    var POICoordinates: CGPoint? = nil
    
    var queueLabel: String?
    var waitingLabel: String?
    var ticketLabel: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

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
                cell.ticketImage.image = UIImage(named: "Settings")
                cell.queueImage.image = UIImage(named: "Settings")
                cell.waitingImage.image = UIImage(named: "Settings")
                
                cell.ticketLabel.text = ticketLabel!
                cell.queueLabel.text = queueLabel!
                cell.waitingLabel.text = waitingLabel!
                
                cell.queueLabel.adjustsFontSizeToFitWidth = true
                cell.waitingLabel.adjustsFontSizeToFitWidth = true
                cell.ticketLabel.adjustsFontSizeToFitWidth = true
                
                cell.layer.borderWidth = 0.5
                cell.layer.borderColor = Colors.darkColor.cgColor
                
                return cell
            } else {
                reusableIdentifier = "MedicalExaminationCheckinKOCell"
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableIdentifier, for: indexPath) as! MedicalExaminationCheckinKOCell
                cell.checkinImage.image = UIImage(named: "check")
                
                cell.layer.borderWidth = 0.5
                cell.layer.borderColor = Colors.darkColor.cgColor
                return cell
            }
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationInformationCell", for: indexPath) as! MedicalExaminationInformationCell
            cell.titleLabel.text = upperExaminationDetail[0].title
            cell.informationLabel.text = upperExaminationDetail[0].information
            
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = Colors.darkColor.cgColor
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationInformationCell", for: indexPath) as! MedicalExaminationInformationCell
            cell.titleLabel.text = upperExaminationDetail[1].title
            cell.informationLabel.text = upperExaminationDetail[1].information
            
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = Colors.darkColor.cgColor
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationInformationCell", for: indexPath) as! MedicalExaminationInformationCell
            cell.titleLabel.text = upperExaminationDetail[2].title
            cell.informationLabel.text = upperExaminationDetail[2].information
            
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = Colors.darkColor.cgColor
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationDescriptionCell", for: indexPath) as! MedicalExaminationDescriptionCell
            cell.descriptionTextView.text = examinationDescriptionText
            
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = Colors.darkColor.cgColor
            return cell
        case 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationInformationCell", for: indexPath) as! MedicalExaminationInformationCell
            cell.titleLabel.text = bottomExaminationDetail[0].title
            cell.informationLabel.text = bottomExaminationDetail[0].information
            
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = Colors.darkColor.cgColor
            return cell
        case 6:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationInformationCell", for: indexPath) as! MedicalExaminationInformationCell
            cell.titleLabel.text = bottomExaminationDetail[1].title
            cell.informationLabel.text = bottomExaminationDetail[1].information
            
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = Colors.darkColor.cgColor
            return cell
        case 7:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicalExaminationButtonCell", for: indexPath) as! MedicalExaminationButtonCell
            cell.button.layer.backgroundColor = Colors.mediumColor.cgColor
            
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = Colors.darkColor.cgColor
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
            width = view.bounds.size.width-20
        case .pad:
            width = view.bounds.size.width-20
        default:
            width = view.bounds.size.width-20
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
            return CGSize(width: width, height: maxHeight)
        case 5:
            return CGSize(width: width, height: mediumHeight)
        case 6:
            return CGSize(width: width, height: mediumHeight)
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
    }
    
    // Funzione che ridimensiona le celle quando si ruota lo schermo
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
    
    
    @IBAction func navigate(_ sender: Any) {
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
    
    // Funzione che salva il contenuto del file JSON
    func parse(json: JSON) {
        queueLabel = "Queue: \(json["queue"])"
        waitingLabel = "Waiting time: \(json["waiting_time"])min"
        ticketLabel = "Your ticket: \(json["ticket"])"
    }
}

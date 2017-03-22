//
//  ExaminationDetailViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 20/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class ExaminationDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var checkinExaminationView: CheckinExamination!
    @IBOutlet weak var bottomTableView: UITableView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var upperTableView: UITableView!
    
    var upperExaminationDetail = [Information]()
    var bottomExaminationDetail = [Information]()
    var examinationDescriptionText = String()
    var checkinDone = true
    var POICoordinates: CGPoint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomTableView.delegate = self
        upperTableView.delegate = self
        bottomTableView.dataSource = self
        upperTableView.dataSource = self
        descriptionText.text = examinationDescriptionText
        if checkinDone {
            loadCheckinDetails()
            loadExaminationCheckinView()
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return upperExaminationDetail.count
        } else if tableView.tag == 1 {
            return bottomExaminationDetail.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpperExaminationCell") as! InformationCell
            cell.titleLabel.text = upperExaminationDetail[indexPath.row].title
            cell.informationLabel.text = upperExaminationDetail[indexPath.row].information
            return cell
        } else if tableView.tag == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BottomExaminationCell") as! InformationCell
            cell.titleLabel.text = bottomExaminationDetail[indexPath.row].title
            cell.informationLabel.text = bottomExaminationDetail[indexPath.row].information
            return cell
        } else {
            return UITableViewCell()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Details"
    }
    
    @IBAction func navigate(_ sender: Any) {
    }
    
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
    
    func parse(json: JSON) {
        checkinExaminationView.queueLabel.text = "Queue: \(json["queue"])"
        checkinExaminationView.waitingLabel.text = "Waiting time: \(json["waiting_time"])min"
        checkinExaminationView.ticketLabel.text = "Your ticket: \(json["ticket"])"
    }
    
    func loadExaminationCheckinView() {
        checkinExaminationView.checkinImage.image = UIImage(named: "check")
        checkinExaminationView.ticketImage.image = UIImage(named: "Settings")
        checkinExaminationView.queueImage.image = UIImage(named: "Settings")
        checkinExaminationView.waitingImage.image = UIImage(named: "Settings")
        
        checkinExaminationView.queueLabel.adjustsFontSizeToFitWidth = true
        checkinExaminationView.waitingLabel.adjustsFontSizeToFitWidth = true
        checkinExaminationView.ticketLabel.adjustsFontSizeToFitWidth = true
    }
}

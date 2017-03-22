//
//  MedicalExaminationViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 19/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class MedicalExaminationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var medicalExaminationTableView: UITableView!
    
    var medicalExaminationSection = MedicalExaminationSectionData.getData(refreshData: false)
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        medicalExaminationTableView.delegate = self
        medicalExaminationTableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        medicalExaminationTableView.addSubview(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return medicalExaminationSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicalExaminationSection[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return medicalExaminationSection[section].heading
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicalExaminationCell", for: indexPath)
        cell.textLabel?.text = (medicalExaminationSection[indexPath.section].items[indexPath.row] as? ExaminationDetail)?.name
        cell.detailTextLabel?.text = "Hour: \((medicalExaminationSection[indexPath.section].items[indexPath.row] as! ExaminationDetail).date). Building: Edificio 27"
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let ed = storyboard?.instantiateViewController(withIdentifier: "ExaminationDetail") as? ExaminationDetailViewController {
            let info1 = ExaminationInformation(title: "Examination:", information: (medicalExaminationSection[indexPath.section].items[indexPath.row] as! ExaminationDetail).name)
            let info2 = ExaminationInformation(title: "Day:", information: (medicalExaminationSection[indexPath.section].items[indexPath.row] as! ExaminationDetail).date)
            let info3 = ExaminationInformation(title: "Hour:", information: (medicalExaminationSection[indexPath.section].items[indexPath.row] as! ExaminationDetail).hour)
            let descriptionText = (medicalExaminationSection[indexPath.section].items[indexPath.row] as! ExaminationDetail).examinationDescription
            let info4 = ExaminationInformation(title: "Doctor:", information: (medicalExaminationSection[indexPath.section].items[indexPath.row] as! ExaminationDetail).doctor)
            
            var info5: ExaminationInformation?
            for poi in POIData.getData() {
                if poi.ID == (medicalExaminationSection[indexPath.section].items[indexPath.row] as! ExaminationDetail).POI_ID {
                    info5 = ExaminationInformation(title: "Building:", information: poi.name)
                    ed.POICoordinates = poi.coordinates
                }
            }
            
            if info5 == nil {
                info5 = ExaminationInformation(title: "Building:", information: "Missing Information")
            }
            ed.upperExaminationDetail.append(info1)
            ed.upperExaminationDetail.append(info2)
            ed.upperExaminationDetail.append(info3)
            ed.examinationDescriptionText = descriptionText
            ed.bottomExaminationDetail.append(info4)
            ed.bottomExaminationDetail.append(info5!)
            
            
            navigationController?.pushViewController(ed, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Medical Examinations"
    }
    
    func refreshData(sender: UIRefreshControl) {
        medicalExaminationSection = MedicalExaminationSectionData.getData(refreshData: true)
        medicalExaminationTableView.reloadData()
        refreshControl.endRefreshing()
    }

}

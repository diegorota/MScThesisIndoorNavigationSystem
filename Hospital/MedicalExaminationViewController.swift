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

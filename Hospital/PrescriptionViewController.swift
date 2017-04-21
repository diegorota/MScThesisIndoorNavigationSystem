//
//  PrescriptionViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 23/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class PrescriptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var prescriptionSection = PrescriptionSectionData.getData(refreshData: false)
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return prescriptionSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prescriptionSection[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return prescriptionSection[section].heading
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionCell", for: indexPath)
        cell.textLabel?.text = (prescriptionSection[indexPath.section].items[indexPath.row] as? Prescription)?.name
        cell.detailTextLabel?.text = "Hour: \((prescriptionSection[indexPath.section].items[indexPath.row] as! Prescription).hour)"
        cell.detailTextLabel?.textColor = Colors.darkColor
        cell.textLabel?.textColor = Colors.darkColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.init(name: "Regular", size: 24)
        header.textLabel?.textColor = UIColor.white
        header.backgroundView?.backgroundColor = Colors.mediumColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Prescriptions"
    }
    
    func refreshData(sender: UIRefreshControl) {
        prescriptionSection = PrescriptionSectionData.getData(refreshData: true)
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

}

//
//  POIViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 22/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class POIViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var POITableView: UITableView!
    var POIList = POIData.getData()
    var filteredPOI = [POIDetail]()
    var resultSearchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        POITableView.delegate = self
        POITableView.dataSource = self
        

        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.prominent
        resultSearchController.searchBar.sizeToFit()
        POITableView.tableHeaderView = resultSearchController.searchBar
        resultSearchController.loadViewIfNeeded()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Places"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if resultSearchController.isActive {
            return filteredPOI.count
        } else {
            return POIList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "POICell", for: indexPath)
        
        if resultSearchController.isActive {
            cell.textLabel?.text = filteredPOI[indexPath.row].name
        } else {
            cell.textLabel?.text = POIList[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let poiView = storyboard?.instantiateViewController(withIdentifier: "POIDetail") as? POIDetailViewController {
            
            var list: [POIDetail]
            if resultSearchController.isActive {
                list = filteredPOI
            } else {
                list = POIList
            }
            let info1 = Information(title: "Name:", information: list[indexPath.row].name)
            let info2 = Information(title: "Hour:", information: list[indexPath.row].hour)
            let info3 = Information(title: "Manager:", information: list[indexPath.row].manager)
            let info4 = Information(title: "Place:", information: list[indexPath.row].building)
            let info5 = Information(title: "Phone number:", information: list[indexPath.row].phoneNumber)
            poiView.informationList.append(info1)
            poiView.informationList.append(info2)
            poiView.informationList.append(info3)
            poiView.informationList.append(info4)
            poiView.informationList.append(info5)
            poiView.placeCoordinates = list[indexPath.row].coordinates
            poiView.placeDescription = list[indexPath.row].POIDescription
            poiView.phoneNumber = list[indexPath.row].phoneNumber
            navigationController?.pushViewController(poiView, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if (searchController.searchBar.text?.characters.count)! > 0 {
            filteredPOI.removeAll(keepingCapacity: false)
            for item in POIList {
                if item.name.lowercased().contains((searchController.searchBar.text?.lowercased())!) {
                    filteredPOI.append(item)
                }
            }
        } else {
            filteredPOI.removeAll(keepingCapacity: false)
            filteredPOI = POIList
        }
        POITableView.reloadData()
    }
    
}

//
//  POIViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 22/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class POIViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var POITableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var POIList = POIData.getData()
    var filteredPOI = [POIDetail]()
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        POITableView.delegate = self
        POITableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.barTintColor = UIColor.white
        searchBar.tintColor = Colors.darkColor
        POITableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Places"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return filteredPOI.count
        } else {
            return POIList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "POICell", for: indexPath)
        
        if isSearching {
            cell.textLabel?.text = filteredPOI[indexPath.row].name
        } else {
            cell.textLabel?.text = POIList[indexPath.row].name
        }
        cell.textLabel?.textColor = Colors.darkColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let poiView = storyboard?.instantiateViewController(withIdentifier: "POIDetail") as? POIDetailViewController {
            
            var list: [POIDetail]
            if isSearching {
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
        resetSearchBar()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.init(name: "Regular", size: 24)
        header.textLabel?.textColor = UIColor.white
        header.backgroundView?.backgroundColor = Colors.mediumColor
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.isEmpty)! {
            isSearching = false
            filteredPOI.removeAll(keepingCapacity: false)
            filteredPOI = POIList
        } else {
            isSearching = true
            filteredPOI.removeAll(keepingCapacity: false)
            for item in POIList {
                if item.name.lowercased().contains((searchText.lowercased())) {
                    filteredPOI.append(item)
                }
            }
        }
        POITableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetSearchBar()
    }
    
    func resetSearchBar() {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredPOI = POIList
        POITableView.reloadData()
    }
    
}

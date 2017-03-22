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
    var resultSearchController: UISearchController?
    var controller: UISearchController?

    override func viewDidLoad() {
        super.viewDidLoad()
        POITableView.delegate = self
        POITableView.dataSource = self
        
        self.resultSearchController = ({
            controller = UISearchController(searchResultsController: nil)
            controller?.dimsBackgroundDuringPresentation = false
            controller?.searchResultsUpdater = self
            controller?.searchBar.sizeToFit()
            POITableView.tableHeaderView = controller?.searchBar
            return controller
        })()
        self.controller?.loadViewIfNeeded()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Places"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let controller = self.resultSearchController else {
            return 0
        }
        
        if controller.isActive {
            return filteredPOI.count
        } else {
            return POIList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "POICell", for: indexPath)
        
        if self.resultSearchController!.isActive {
            cell.textLabel?.text = filteredPOI[indexPath.row].name
        } else {
            cell.textLabel?.text = POIList[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let ed = storyboard?.instantiateViewController(withIdentifier: "POIDetail") {
            navigationController?.pushViewController(ed, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        POIFilter(text: searchController.searchBar.text!)
    }
    
    func POIFilter(text: String) {
        filteredPOI.removeAll(keepingCapacity: false)
        for item in POIList {
            if item.name.lowercased().contains(text.lowercased()) {
                filteredPOI.append(item)
            }
        }
        POITableView.reloadData()
    }
    
}

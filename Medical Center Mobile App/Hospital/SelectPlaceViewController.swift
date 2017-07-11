//
//  SelectPlaceViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 12/05/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

protocol SelectPlaceViewControllerDelegate {
    func placeViewControllerDidSelect(value: Vertex?, kindOfButton: Int)
}

class SelectPlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: SelectPlaceViewControllerDelegate?
    var canvas: Array<Vertex> = Array<Vertex>()
    var kindOfButton: Int!
    var selectedVertex: Vertex? = nil
    var lastSelection: IndexPath?
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return canvas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "vertex", for: indexPath)
        cell.textLabel?.text = canvas[indexPath.row].key!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newCell = tableView.cellForRow(at: indexPath)
        newCell?.accessoryType = UITableViewCellAccessoryType.checkmark
        if let lastSelection = lastSelection {
            let oldCell = tableView.cellForRow(at: lastSelection)
            oldCell?.accessoryType = UITableViewCellAccessoryType.none
        }
        selectedVertex = canvas[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.placeViewControllerDidSelect(value: selectedVertex, kindOfButton: kindOfButton)
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.placeViewControllerDidSelect(value: selectedVertex, kindOfButton: kindOfButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if kindOfButton == 0 {
            navigationController?.visibleViewController?.title = "Starting Point"
        } else {
            navigationController?.visibleViewController?.title = "Destination Point"
        }
    }

}

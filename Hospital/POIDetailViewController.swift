//
//  POIDetailViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 22/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class POIDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerImage: UIImageView!
    
    let maxHeaderHeight: CGFloat = 200
    let minHeaderHeight: CGFloat = 44
    var previousScrollOffset: CGFloat = 0.0
    
    var informationList = [Information]()
    var placeCoordinates: CGPoint?
    var placeDescription: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informationList.count + 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! TwoButtonsCell
            cell.leftButton.setImage(UIImage(named: "Settings"), for: .normal)
            cell.rightButton.setImage(UIImage(named: "Settings"), for: .normal)
            return cell
            
        } else if (indexPath.row > 0) && (indexPath.row < (informationList.count+1)) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell", for: indexPath) as! InformationCell
            cell.titleLabel.text = informationList[indexPath.row-1].title
            cell.informationLabel.text = informationList[indexPath.row-1].information
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! DescriptionCell
            cell.descriptionText.text = placeDescription
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 88
            
        } else if (indexPath.row > 0) && (indexPath.row < (informationList.count+1)) {
            return 44
        } else {
            return 132
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerHeightConstraint.constant = maxHeaderHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - previousScrollOffset
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        var newHeight = headerHeightConstraint.constant
        if isScrollingDown {
            newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
        } else if isScrollingUp {
            newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
        }
        
        if newHeight != self.headerHeightConstraint.constant {
            self.headerHeightConstraint.constant = newHeight
            self.setScrollPosition(position: self.previousScrollOffset)
        }
        
        self.previousScrollOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.headerHeightConstraint.constant > midPoint {
            expandHeader()
        } else {
            collapseHeader()
        }
    }
    
    func setScrollPosition(position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }
    
    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.minHeaderHeight
            // Manipulate UI elements within the header here
            self.view.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            // Manipulate UI elements within the header here
            self.view.layoutIfNeeded()
        })
    }

}

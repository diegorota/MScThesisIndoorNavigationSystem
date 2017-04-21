//
//  POIDetailViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 22/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

struct StretchyHeader {
    let headerHeight: CGFloat = 250
    let headerCut: CGFloat = 0
}

class POIDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var headerView: UIView!
    
    var newHeaderLayer: CAShapeLayer!
    
    var informationList = [Information]()
    var placeCoordinates: CGPoint?
    var placeDescription: String?
    var phoneNumber: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        updateView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNewView(width: self.view.bounds.width)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setNewView(width: size.width)
    }
    
    func updateView() {
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.rowHeight = UITableViewAutomaticDimension
        newHeaderLayer = CAShapeLayer()
        newHeaderLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = newHeaderLayer
        
        //let newHeight = StretchyHeader().headerHeight - StretchyHeader().headerCut/2
        let newHeight = self.view.bounds.size.height/4 - StretchyHeader().headerCut/2
        tableView.contentInset = UIEdgeInsets(top: newHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -newHeight)
        setNewView(width: self.view.bounds.width)
    }
    
    func setNewView(width: CGFloat) {
        //let newHeight = StretchyHeader().headerHeight - StretchyHeader().headerCut/2
        let newHeight = self.view.bounds.size.height/4 - StretchyHeader().headerCut/2
        //var getHeaderFrame = CGRect(x: 0, y: -newHeight, width: tableView.bounds.width, height: StretchyHeader().headerHeight)
        var getHeaderFrame = CGRect(x: 0, y: -newHeight, width: width, height: self.view.bounds.size.height/4)
        
        if tableView.contentOffset.y < newHeight {
            getHeaderFrame.origin.y = tableView.contentOffset.y
            getHeaderFrame.size.height = -tableView.contentOffset.y + StretchyHeader().headerCut/2
        }
        
        headerView.frame = getHeaderFrame
        let cutDirection = UIBezierPath()
        cutDirection.move(to: CGPoint(x: 0, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: getHeaderFrame.height))
        cutDirection.addLine(to: CGPoint(x: 0, y: getHeaderFrame.height - StretchyHeader().headerCut))
        newHeaderLayer.path = cutDirection.cgPath
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return informationList.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! TwoButtonsCell
            cell.leftButton.setImage(UIImage(named: "phone")?.withRenderingMode(.alwaysTemplate), for: .normal)
            cell.leftButton.tintColor = UIColor.white
            cell.rightButton.setImage(UIImage(named: "navigate")?.withRenderingMode(.alwaysTemplate), for: .normal)
            cell.rightButton.tintColor = UIColor.white
            cell.backgroundColor = Colors.mediumColor
            return cell
            
        } else if (indexPath.row > 0) && (indexPath.row < (informationList.count+1)) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell", for: indexPath) as! InformationCell
            cell.titleLabel.text = informationList[indexPath.row-1].title
            cell.titleLabel.textColor = Colors.darkColor
            cell.informationLabel.text = informationList[indexPath.row-1].information
            cell.informationLabel.textColor = Colors.darkColor
            cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
            cell.bounds.size.width = self.view.bounds.size.width-40
            if indexPath.row == 5 {
                cell.isUserInteractionEnabled = true
            }
            return cell
            
        } else if indexPath.row == (informationList.count+1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! DescriptionCell
            cell.descriptionText.text = placeDescription
            cell.descriptionText.textColor = Colors.darkColor
            cell.descriptionLabel.textColor = Colors.darkColor
            cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
            cell.bounds.size.width = self.view.bounds.size.width-40
            return cell

        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            callNumber(phoneNumber: phoneNumber!)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 50
        } else if (indexPath.row > 0) && (indexPath.row < (informationList.count+1)) {
            return 44
        } else {
            return 132
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.visibleViewController?.title = "Details"
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func POIAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            callNumber(phoneNumber: phoneNumber!)
        case 1:
            print("naviga")
        default:
            print("errore")
        }
    }

}

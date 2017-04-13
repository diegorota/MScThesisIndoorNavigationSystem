//
//  NewsViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 23/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var newsList = [News]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "News"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)

        self.view.layoutIfNeeded()
        self.tableView.contentOffset = CGPoint(x:0, y:-self.refreshControl.frame.size.height);
        self.refreshControl.beginRefreshing()
        DispatchQueue.global(qos: .userInitiated).async {
            let list = NewsData.getData(refreshData: false)
            DispatchQueue.main.async {
                if list != nil {
                    self.newsList = list!
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                } else {
                    self.showError()
                }
            }
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        cell.titleLabel.text = self.newsList[indexPath.row].title
        cell.postImage?.image = self.newsList[indexPath.row].postImage
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return max(UITableViewAutomaticDimension, 160.00)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return max(UITableViewAutomaticDimension, 160.00)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let svc = SFSafariViewController(url: newsList[indexPath.row].urlSite)
        self.present(svc, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshData(sender: UIRefreshControl) {
        DispatchQueue.global(qos: .userInitiated).async {
            let list = NewsData.getData(refreshData: true)
            DispatchQueue.main.async {
                if list != nil {
                    self.newsList = list!
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                } else {
                    self.refreshControl.endRefreshing()
                    self.showError()
                }
            }
        }
    }

    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}

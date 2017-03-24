//
//  NewsViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 23/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

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
        
        DispatchQueue.global(qos: .userInitiated).async {
            let list = NewsData.getData(refreshData: false)
            DispatchQueue.main.async {
                if list != nil {
                    self.newsList = list!
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
        //cell.descriptionLabel.text = self.newsList[indexPath.row].description
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: self.newsList[indexPath.row].urlImage)
            DispatchQueue.main.async {
                cell.postImage?.image = UIImage(data: data!)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
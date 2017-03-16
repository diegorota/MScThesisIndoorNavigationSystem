//
//  SettingsViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 16/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var surname: UILabel!
    @IBOutlet weak var fiscalCode: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.text = PersonLogged.name
        surname.text = PersonLogged.surname
        fiscalCode.text = PersonLogged.fiscalCode
        image.image = UIImage(named: "User_logo")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 15/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var patientCode: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var signinButton: UIButton!
    
    var rememberMe = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rememberMe = rememberMeSwitch.isOn
        
        title = "Login"
        
        signinButton.layer.cornerRadius = 5
        patientCode.layer.cornerRadius = 5
        password.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // funzione che cambia lo stato di rememberMe quando l'utente preme lo switch per memorizzare o meno i dati di login
    @IBAction func changeSwitch(_ sender: Any) {
        rememberMe = rememberMeSwitch.isOn
    }
    
    @IBAction func doLogin(_ sender: Any) {
        
        if patientCode.text == "" || password.text == "" {
            let ac = UIAlertController(title: "Errore", message: "Devi inserire il tuo codice paziente e la tua password per accedere.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continua", style: .default))
            present(ac, animated: true)
        }
        
        if checkLogin() {
            // passa alla schermata Home
        } else {
            let ac = UIAlertController(title: "Errore login", message: "Codice paziente o password errati. Inserisci nuovamente le tue credenziali.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continua", style: .default))
            present(ac, animated: true)
        }
        
    }
    
    // Da implementare controllo validità patientCode e Passeord. Allo stato attuale, questo metodo ritorna sempre true.
    func checkLogin() -> Bool {
        return false
    }
}


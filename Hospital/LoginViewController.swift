//
//  ViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 15/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var patientCode: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var signinButton: UIButton!
    
    var rememberMe = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        rememberMe = rememberMeSwitch.isOn
        
        signinButton.layer.cornerRadius = 5
        patientCode.layer.cornerRadius = 5
        password.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Funzione che cambia lo stato di rememberMe quando l'utente preme lo switch per memorizzare o meno i dati di login
    @IBAction func changeSwitch(_ sender: Any) {
        rememberMe = rememberMeSwitch.isOn
    }
    
    // Funzione che controlla se sono stati compilati i campi di login e chiama la funzione checkLogin() per verificare la validità delle credenziali.
    // Se le credenziali sono corrette, crea la schermata di Home, altrimenti mostra un messaggio di errore.
    @IBAction func doLogin(_ sender: Any) {
        
        if patientCode.text == "" || password.text == "" {
            let ac = UIAlertController(title: "Errore", message: "Devi inserire il tuo codice paziente e la tua password per accedere.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continua", style: .default))
            present(ac, animated: true)
        }
        
        if checkLogin() {
            if let home = storyboard?.instantiateViewController(withIdentifier: "HomeNavigation") {
                present(home, animated: true)
            }
        } else {
            let ac = UIAlertController(title: "Errore login", message: "Codice paziente o password errati. Inserisci nuovamente le tue credenziali.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continua", style: .default))
            present(ac, animated: true)
        }
        
    }
    
    // Funziona che verifica che le credenzuali siano corrette. Ritorna true in caso affermativo, altrimenti false.
    // Da implementare controllo validità patientCode e Passeord. Allo stato attuale, questo metodo ritorna sempre true.
    func checkLogin() -> Bool {
        if let path = Bundle.main.path(forResource: "json/login", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) {
                let json = JSON(data: data)
                if json["login_response"].boolValue == true {
                    defaults.setValue(json["name"].stringValue, forKey: UserDefaultsKeys.nameKey)
                    defaults.setValue(json["surname"].stringValue, forKey: UserDefaultsKeys.surnameKey)
                    defaults.setValue(json["fiscalcode"].stringValue, forKey: UserDefaultsKeys.fiscalCodeKey)
                    defaults.setValue(json["hospitalized"].stringValue, forKey: UserDefaultsKeys.hospitalizedKey)
                    defaults.setValue(rememberMe, forKey: UserDefaultsKeys.rememberMeKey)
                    defaults.synchronize()
                    return true
                }
            }
        } else {
            let ac = UIAlertController(title: "Errore", message: "Si è verificato un errore di connessione. Riprova.", preferredStyle: .alert)
            present(ac,animated: true)
        }
        return false
    }
}


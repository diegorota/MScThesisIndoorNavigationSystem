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
    @IBOutlet weak var rememberMeLabel: UILabel!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var touchIDButton: UIButton!
    
    var rememberMe = false
    var touchIDEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        touchIDEnabled = defaults.bool(forKey: UserDefaultsKeys.touchIDKey)
        rememberMe = rememberMeSwitch.isOn
        touchIDButton.isEnabled = touchIDEnabled
        signinButton.layer.backgroundColor = Colors.mediumColor.cgColor
        touchIDButton.tintColor = Colors.mediumColor
        patientCode.attributedPlaceholder = NSAttributedString(string: "Patient code", attributes: [NSForegroundColorAttributeName:Colors.darkColor, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:Colors.darkColor, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        rememberMeLabel.textColor = Colors.mediumColor
        
        if touchIDEnabled {
            self.touchIDAccess()
        }
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
            let ac = UIAlertController(title: "Error", message: "You must enter your patient code and your password to access.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default))
            present(ac, animated: true)
        }
        
        if checkLogin() {
            if let home = storyboard?.instantiateViewController(withIdentifier: "HomeNavigation") {
                present(home, animated: true)
            }
        } else {
            let ac = UIAlertController(title: "Login Error", message: "Wrong patient code or password. Insert again your credentials.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default))
            present(ac, animated: true)
        }
        
    }
    
    // Funzione che verifica che le credenzuali siano corrette. Ritorna true in caso affermativo, altrimenti false.
    // Da implementare controllo validità patientCode e Password. Allo stato attuale, questo metodo ritorna sempre true.
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
                    
                    let context = LAContext()
                    var error: NSError?
                    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                        defaults.set(true, forKey: UserDefaultsKeys.touchIDKey)
                    }
                    
                    defaults.synchronize()
                    return true
                }
            }
        } else {
            let ac = UIAlertController(title: "Error", message: "There was a connection problem. Check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default))
            present(ac,animated: true)
        }
        return false
    }
    
    // Funzione che abilita l'accesso tramite Touch ID
    func touchIDAccess() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Access with your fingerprint."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        if let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeNavigation") {
                            self.present(home, animated: true)
                        }
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func useTouchID(_ sender: UIButton) {
        touchIDAccess()
    }
}


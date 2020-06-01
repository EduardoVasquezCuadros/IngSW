//
//  LoginViewController.swift
//  checkPerson
//
//  Created by Eduardo Vasquez on 24/05/20.
//  Copyright © 2020 Bosque. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var identificationTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
//    Configuración de la interfaz gráfica
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loginButton.layer.cornerRadius = 5
        self.loginButton.layer.borderWidth = 1
        self.loginButton.layer.borderColor = UIColor.gray.cgColor
    
        hideKeyboardWhenTappedAround()
    }
    
//  Función que verifica si el usuario ya esta registrado y permite ingresar
    @IBAction func login(_ sender: Any) {
        var logged = false
        let model = Model()
        
        model.agent(response: { (agent) in
            for person in agent {
                let letterNumber = self.passTextField.text?.count
                if person.id == self.identificationTextField.text && person.pass == self.passTextField.text && letterNumber! >= 5 && letterNumber! <= 10 {
                    logged = true
                    let vc: ViewController = self.storyboard!.instantiateViewController(withIdentifier: "ViewController") as! ViewController

                    vc.name = "\(person.status.capitalizingFirstLetter()): \(person.name.capitalizingFirstLetter()) \(person.lastName.capitalizingFirstLetter())"
                    self.present(vc, animated: true, completion: nil)
                }
            }
            
            if !logged {
                self.alertView(title: "Ingreso", message: "Por favor verifique su número de identificación y contraseña")
            }
        })
    }
}

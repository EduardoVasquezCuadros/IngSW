//
//  RegisterViewController.swift
//  checkPerson
//
//  Created by Eduardo Vasquez on 25/05/20.
//  Copyright © 2020 Bosque. All rights reserved.
//

import UIKit
import AAPickerView

class RegisterViewController: UIViewController {
    @IBOutlet weak var identificationTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var forceTextField: AAPickerView!
    @IBOutlet weak var status: AAPickerView!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    /**
     Configuración de la interfaz gráfica
     
     - parameter : nil
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = UIColor.gray.cgColor
        
        hideKeyboardWhenTappedAround()
        configPickerForce()
        configPickerStatus()
    }
    
    /**
     Traer información de la base de datos y agregarla a la interfaz gráfica
     
     - parameter : nil
     */
    func configPickerForce() {
        let model = Model()
        model.force { (force) in
            let stringData = force
            
            self.forceTextField.pickerType = .string(data: stringData)
            self.forceTextField.heightForRow = 40
            self.forceTextField.pickerRow.font = UIFont(name: "American Typewriter", size: 30)
            
            self.forceTextField.toolbar.barTintColor = .darkGray
            self.forceTextField.toolbar.tintColor = .black
        }
    }
    
    /**
    Traer información de la base de datos y agregarla a la interfaz gráfica
    
    - parameter : nil
    */
    func configPickerStatus() {
        let model = Model()
        model.status { (statusString) in
            let stringData = statusString
            
            self.status.pickerType = .string(data: stringData)
            self.status.heightForRow = 40
            self.status.pickerRow.font = UIFont(name: "American Typewriter", size: 30)
            
            self.status.toolbar.barTintColor = .darkGray
            self.status.toolbar.tintColor = .black
        }
    }
    
    /**
    Función que verifica la existencia de todos los datos de registro y hace el registro si no existe el usuario en la base de datos
    
    - parameter sender: botón clickeado
    */
    @IBAction func registerTapped(_ sender: Any) {
        var registred = false
        
        if !checkingData() {
            return
        }
        
        guard let email = emailTextField.text,
            let pass = passTextField.text,
            let name = nameTextField.text,
            let force = forceTextField.text,
            let id = identificationTextField.text,
            let lastName = lastNameTextField.text,
            let status = status.text else {
                self.alertView(title: "Registro", message: "Por favor verifique la información ingresada")
                
                return
        }
        
        guard let identification = Int(id) else {
            return
        }
        
        let information: [String: Any] = ["correo": email, "contraseña": pass, "nombres": name, "fuerzaPublica": force, "identificacion": identification, "idFuerza": 1, "apellidos": lastName, "rango": status]
        
        let model = Model()
        model.agent { (agent) in
            for person in agent {
                if person.id == id || person.email == email {
                    registred = true
                }
            }
            if !registred {
                model.toRegister(agent: information) { (data) in
                    self.alertView(title: "Registro", message: data)
                    self.dismiss(animated: true, completion: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    /**
    Función que verificaque todos los datos ingresados por el usuario cumplan con lo solicitado por la base de datos
    
    - parameter :
     
    - return : Verificación de los campos del registro
    */
    func checkingData() -> Bool {
        guard let email = emailTextField.text,
            let pass = passTextField.text,
            let name = nameTextField.text,
            let force = forceTextField.text,
            let id = identificationTextField.text,
            let lastName = lastNameTextField.text,
            let status = status.text else {
                self.alertView(title: "Registro", message: "Por favor verifique la información ingresada")
                
                return false
        }
        
        if name.isEmpty || lastName.isEmpty || pass.isEmpty || email.isEmpty || force.isEmpty || id.isEmpty || status.isEmpty {
            self.alertView(title: "Registro", message: "Por favor introduzca toda la información en los campos de texto.")
            return false
        }
        
        if id.count <= 5 || id.count >= 10 {
            self.alertView(title: "Registro", message: "Por favor verifique la cantidad de números de su cédula de ciudadanía.")
            return false
        }
        
        if !isValidEmail(email: email) {
            self.alertView(title: "Registro", message: "Por favor verifique su dirección de correo electrónico porque no cumple con los criterios jaimemora@unbosque.edu.co")
            return false
        }
        
        if !validate(password: pass) || pass.count < 8  {
            self.alertView(title: "Registro", message: "Recuerde que su contraseña debe tener una mayúscula, un número y debe ser mayor a 7 caracteres.")
            return false
        }
        
        return true
    }
    
    /**
    Verificación del formato del email
    
    - parameter email : email que será verificado
    - return : Verificación del formato del email
    */
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    /**
    Verificación de los datos minimos de la contraseña
    
    - parameter password : contraseña que será verificado
    - return : Verificación del formato de la contraseña
    */
    func validate(password: String) -> Bool {
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        guard texttest.evaluate(with: password) else { return false }
        
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        guard texttest1.evaluate(with: password) else { return false }
        
        return true
    }
}

/**
Utilidades gráficas del sistema

- parameter : nil
*/
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func alertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

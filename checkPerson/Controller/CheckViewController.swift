//
//  CheckViewController.swift
//  checkPerson
//
//  Created by Eduardo Vasquez on 21/05/20.
//  Copyright © 2020 Bosque. All rights reserved.
//

import UIKit

class CheckViewController: UIViewController {
    
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var informationText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//  Verifica si el usuario esta registrado como requerido y muestra esta información
    func setupImage(check: Bool, name: String, lastName: String, identification: String) {
        if checkImage != nil {
            let imageName = !check ? "check.png" : "error.png"
            let text = !check ? ("El número de cédula no se encuentra solicitado por ninguna autoridad Colombiana") : ("\(name.capitalizingFirstLetter()) \(lastName.capitalizingFirstLetter()) con número de cédula \(identification) es solicitado por la justicia Colombiana")
            
            checkImage.image = UIImage(named: imageName)
            informationText.text = text
        }
    }
}

// extensión que pone la primera letra de una palabra en mayuscula
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

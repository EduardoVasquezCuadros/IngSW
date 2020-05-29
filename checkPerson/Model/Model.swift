//
//  Model.swift
//  checkPerson
//
//  Created by Eduardo Vasquez on 23/05/20.
//  Copyright © 2020 Bosque. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class Model: NSObject {
    var firDatabaseReference = Database.database().reference()

//  Función que se encarga en traer toda la información del ciudadano y retornarla a la función que la solicito
    func citizen(response: @escaping ([Citizen]) -> Void) {
        
        var citizenArray = [Citizen]()
                
        _ = firDatabaseReference.observe(.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : Any] ?? [:]
            
            guard let citizens = postDict["ciudadanos"] as? [String: Any] else {
                return
            }
            
            for person in citizens {
                let data = person.value as! [String: Any]
                
                guard let id = data["identificacion"] as? Int,
                      let name = data["nombres"] as? String,
                      let lastname = data["apellidos"] as? String,
                      let requered = data["esRequerido"] as? Bool else {
                        return
                }
                
                let idString = String(id)
                let citizen = Citizen(name: name, lastName: lastname, id: idString, requered: requered)
                citizenArray.append(citizen)
                
            }
            response(citizenArray)
            self.firDatabaseReference.removeAllObservers()
        })
        
    }
    
//  Función que se encarga en traer toda la información del funcionario y retornarla a la función que la solicito
    func agent(response: @escaping ([Agent]) -> Void) {
        var agentArray = [Agent]()
                
        _ = firDatabaseReference.observe(.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : Any] ?? [:]
            
            guard let agents = postDict["funcionario"] as? [String: Any] else {
                return
            }
            
            for person in agents {
                
                guard let data = person.value as? [String: Any],
                      let id = data["identificacion"] as? Int,
                      let email = data["correo"] as? String,
                      let pass = data["contraseña"] as? String,
                      let name = data["nombres"] as? String,
                      let lastname = data["apellidos"] as? String,
                      let status = data["rango"] as? String else {
                        return
                }
                
                let idString = String(id)
                let agent = Agent(name: name, lastName: lastname, email: email, pass: pass, id: idString, status: status)
                agentArray.append(agent)
            }
            response(agentArray)
            self.firDatabaseReference.removeAllObservers()
        })
    }

//  Función que se encarga en traer toda la información de la fuerza publica disponible y retornarla a la función que la solicito
    func force(response: @escaping ([String]) -> Void) {
        var forceArray = [String]()
                
        _ = firDatabaseReference.observe(.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : Any] ?? [:]
            
            guard let agents = postDict["fuerza"] as? [Any] else {
                return
            }
            
            for forces in agents {
                guard let data = forces as? [String: Any],
                    let force = data["nombre"] as? String else {
                        return
                }
                forceArray.append(force)
            }
            response(forceArray)
            self.firDatabaseReference.removeAllObservers()
        })
    }
    
//  Función que se encarga en traer toda la información de rango de fuerza publica disponible y retornarla a la función que la solicito
    func status(response: @escaping ([String]) -> Void) {
        var statusArray = [String]()
                
        _ = firDatabaseReference.observe(.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : Any] ?? [:]
            guard let agents = postDict["rango"] as? [Any] else {
                return
            }
            
            for forces in agents {
                guard let data = forces as? [String: Any],
                    let force = data["rango"] as? String else {
                        return
                }
                statusArray.append(force)
            }
            response(statusArray)
            self.firDatabaseReference.removeAllObservers()
        })
    }
    
//  Función que se encarga de registrar al funcionario de la fuerza publica y retorna la respuesta del servidor
    func toRegister(agent:[String:Any], response: @escaping (String) -> Void) {
        
        firDatabaseReference = Database.database().reference()
        let dataBase = firDatabaseReference.child("funcionario")
        guard let key = dataBase.childByAutoId().key else { return }

        dataBase.child(key).setValue(agent) {(error:Error?, ref:DatabaseReference) in
            if let error = error {
                response("Los Datos no pudieron ser guardados: \(error).")
            } else {
                response("¡Su registro ha sido exitoso!")
            }
        }
    }
}

// Estructura local del ciudadano
struct Citizen {
    var name: String
    var lastName: String
    var id: String
    var requered: Bool
}

// Estructura local del funcionario 
struct Agent {
    var name: String
    var lastName: String
    var email: String
    var pass: String
    var id: String
    var status: String
}

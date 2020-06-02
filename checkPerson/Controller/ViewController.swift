//
//  ViewController.swift
//  checkPerson
//
//  Created by Eduardo Vasquez on 5/18/20.
//  Copyright © 2020 Bosque. All rights reserved.
//

import AVFoundation
import UIKit
import FirebaseDatabase
import Firebase

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var identificationTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var scannerButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!

    lazy var vision = Vision.vision()
    let session = AVCaptureSession()
    var barcodeDetector :VisionBarcodeDetector?
    var imageLayer: AVCaptureVideoPreviewLayer!
    var name: String = ""
   
    /**
       Configuración de la interfaz gráfica
       
       - parameter : nil
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        
        self.nameLabel.text = name

        searchButton.layer.cornerRadius = 5
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = UIColor.gray.cgColor
        
        scannerButton.layer.cornerRadius = 5
        scannerButton.layer.borderWidth = 1
        scannerButton.layer.borderColor = UIColor.gray.cgColor
        
        hideKeyboardWhenTappedAround()
    }
    /**
       Configuración de camara
       
       - parameter sender: nil
    */
    func setupCamera() {
        session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
    }
    
    /**
       Boton de búsqueda por texto
       
       - parameter sender: Button clickeado
    */
    @IBAction func SearchByText(_ sender: Any) {
        guard let identification = identificationTextField.text else {
            return
        }
        let identificationNumber = identification.count
        
        if identificationNumber >= 5 && identificationNumber <= 10 {
            let model = Model()
            model.citizen { (citizen) in
                self.search(identification: identification, citizen: citizen)
            }
        } else {
            self.alertView(title: "Verificación", message: "Por favor verifique el número de identificación, no cumple con la longitud")
        }
    }
    
    /**
       Boton de búsqueda por scanner
       
       - parameter sender: Button clickeado
    */
    @IBAction func searchByCamera(_ sender: Any) {
        startLiveVideo()
        barcodeDetector = vision.barcodeDetector()
    }
    
    /**
       Búsqueda de la cédula de la ciudadania
       
       - parameter identification: Número de cedula a buscar
       - parameter citizen: lista de ciudadanos para hacer la búsqueda
    */
    func search(identification: String, citizen: [Citizen]) {
        var founded = false
        var name = ""
        var lastName = ""
        var crimeId = ""
        
        for person in citizen {
            if identification.contains(person.id) && person.requered {
                name = person.name
                lastName = person.lastName
                crimeId = person.id
                founded = true
                break
            }
        }
        self.showState(check: founded, name: name, lastName: lastName, identification: crimeId)
    }
    
    /**
       Mostrar la interfaz gráfica del lector de PDF147
       
       - parameter identification: nil
    */
    private func startLiveVideo() {
        identificationTextField.resignFirstResponder()
        
        imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        imageLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(imageLayer)
        
        session.startRunning()
    }
    
    /**
       Función que se acciona automaticamente cuando el scanner consigue un código PDF147
       
       - parameter output: Lectura que se esta llevando acabo por la camara
       - parameter didOutput: Información capturada por la camara
       - parameter connection: Tipo de códigos que puede capturar la camara
    */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if let barcodeDetector = self.barcodeDetector {
            let visionImage = VisionImage(buffer: sampleBuffer)            
            barcodeDetector.detect(in: visionImage) { (barcodes, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                for barcode in barcodes! {
                    self.session.stopRunning()
                    let code = barcode.rawValue!
                    let model = Model()
                    model.citizen { (citizen) in
                        self.search(identification: code, citizen: citizen)
                        self.imageLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                    }
                }
            }
        }
    }
    
    /**
       Se presenta la pantalla que indica si el ciudadano es requerido o no
       
       - parameter check: Variable que indica si el ciudadano es requerido
       - parameter name: Nombre del ciudadano requerido
       - parameter lastname: Apellido del ciudadano requerido
    */
    private func showState(check: Bool, name: String, lastName: String, identification: String) {
        let viewC = CheckViewController()
        self.present(viewC, animated: true, completion: nil)
        viewC.setupImage(check: check, name: name, lastName: lastName, identification: identification)
    }
}

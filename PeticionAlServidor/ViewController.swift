//
//  ViewController.swift
//  PeticionAlServidor
//
//  Created by Administrador on 07/05/16.
//  Copyright © 2016 ITESO. All rights reserved.
//

import UIKit
import SystemConfiguration

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var isbn: UITextField!
    @IBOutlet weak var respuestaServidor: UITextView!
    
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var autor: UILabel!
    @IBOutlet weak var portada: UILabel!
    
    
    @IBAction func limpiarISBN(sender: AnyObject) {
        self.isbn.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.isbn.delegate = self
        //sincrono()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sincrono(){        //espera la respuesta del servidor antes de seguir trabajando
        
        if isConnectedToNetwork() == true { //si esta conectado a internet
            print("Internet connection OK")
            var urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
            urls += self.isbn.text!
            
            let url = NSURL(string: urls)
            let datos:NSData? = NSData(contentsOfURL: url!)
            //let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
            
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                print(json)
                
                if json.count > 0{
                    let response = json as! NSDictionary
                    let dico1 = response["ISBN:"+self.isbn.text!] as! NSDictionary
                    let dico2 = dico1["authors"] as! NSArray
                    let dico3 =  dico1["title"] as! NSString as String
                    
                    print(dico3)
                    self.titulo.text = dico3
                    
                    for dico in dico2 {
                        print(dico["name"] as! NSString as String)
                        
                        self.autor.text =  self.autor.text! + (dico["name"] as! NSString as String) 
                    }
                    
                } else {
                    let alert = UIAlertController(title: "Error en búsqueda", message: "ISBN no encontrado", preferredStyle: .Alert)
                    alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: {
                        (action) -> Void in
                        print("No se encontró el ISBN")
                        self.titulo.text = ""
                        self.autor.text = ""
                    })))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
            catch _ {
                print("Error")
            }
            
            //print(texto!)
            //self.respuestaServidor.text = texto! as String
        } else {                            //en caso que falle la conexión
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "Falla en conexión", message: "Asegurate de tener conexión a internet.", preferredStyle: .Alert)
            alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: {
                (action) -> Void in
               print("fallo de conexión")
            })))
                
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }

    @IBAction func textFieldDoneEditing(sender: UIScrollView){   //al darle enter desaparece el teclado
        sender.resignFirstResponder() //desaparece el teclado
        
        self.titulo.text = ""
        self.autor.text = ""
        sincrono()
    }
    
    func isConnectedToNetwork() -> Bool {       //método para comprobar la conexión a internet
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .Reachable
        let needsConnection = flags == .ConnectionRequired
        
        return isReachable && !needsConnection
        
    }

}


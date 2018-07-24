//
//  ViewController.swift
//  HalalBytes
//
//  Created by Ammar Waheed on 22/04/2018.
//  Copyright © 2018 Ammar Waheed. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import MapKit
import CoreLocation
class LoginViewController: UIViewController,FBSDKLoginButtonDelegate   {
let loginButton = FBSDKLoginButton()
    
    @IBOutlet weak var halalbitesLogo: UIImageView!
    @IBOutlet weak var text: UILabel!
  
    var buttonname:String = ""
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
   
    override func viewDidLoad() {
        
       
        super.viewDidLoad()
       print(loginButton.titleLabel?.text)
    

        self.loginButton.readPermissions = ["public_profile" , "email"]
        self.view.addSubview(self.loginButton)
        self.loginButton.translatesAutoresizingMaskIntoConstraints = false
        self.loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.loginButton.topAnchor.constraint(equalTo: halalbitesLogo.topAnchor , constant: 140).isActive = true
        self.loginButton.widthAnchor.constraint(equalToConstant: 350).isActive = true
        self.loginButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.text.translatesAutoresizingMaskIntoConstraints = false
        self.text.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.text.topAnchor.constraint(equalTo: halalbitesLogo.topAnchor , constant: 200).isActive = true
        self.text.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        self.text.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        self.loginButton.frame = CGRect(x: 12, y: 250, width: 350, height: 44)
        self.loginButton.layer.cornerRadius = 22
        self.loginButton.layer.shadowOpacity = 0.25
        self.loginButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.loginButton.layer.shadowRadius = 14
            self.self.loginButton.isHidden = false
            
    
        
        
        loginButton.delegate = self as! FBSDKLoginButtonDelegate
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {

        
        if error != nil{
            self.loginButton.isHidden = false
            
        }else if result.isCancelled{
        
            self.loginButton.isHidden = false
          
        }else{
            let uistoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            uistoryboard.instantiateInitialViewController()
            let homeviewcontroller :UIViewController = uistoryboard.instantiateViewController(withIdentifier: "homeview")
            self.present(homeviewcontroller, animated: true, completion: nil)
            print("SuccessFull")
         
        }
        
        
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("LOGGED OUT")
    }
   
}


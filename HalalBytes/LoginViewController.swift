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
import TweeTextField
import TransitionButton
import Alamofire
import CoreData
extension String {
    
    var isValidEmail1: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: self)
    }
}
class LoginViewController: UIViewController,FBSDKLoginButtonDelegate   {
let loginButton = FBSDKLoginButton()
    
    @IBOutlet weak var halalbitesLogo: UIImageView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet private weak var emailTextField: TweeAttributedTextField!
    @IBOutlet weak var PasswordTextField: TweeAttributedTextField!
    @IBOutlet weak var SignInButton: TransitionButton!
    var isOverCurrentContextTransition = false
  
    var buttonname:String = ""
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
   
    override func viewDidLoad() {
        
       
        super.viewDidLoad()
//       print(loginButton.titleLabel?.text)
//    
//
//        self.loginButton.readPermissions = ["public_profile" , "email"]
//        self.view.addSubview(self.loginButton)
//                loginButton.isHidden  = true
//        self.loginButton.translatesAutoresizingMaskIntoConstraints = false
//        self.loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        self.loginButton.topAnchor.constraint(equalTo: halalbitesLogo.topAnchor , constant: 140).isActive = true
//        self.loginButton.widthAnchor.constraint(equalToConstant: 350).isActive = true
//        self.loginButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        
//        self.text.translatesAutoresizingMaskIntoConstraints = false
//        self.text.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        self.text.topAnchor.constraint(equalTo: halalbitesLogo.topAnchor , constant: 200).isActive = true
//        self.text.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
//        self.text.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
//        
//        self.loginButton.frame = CGRect(x: 12, y: 250, width: 350, height: 44)
//        self.loginButton.layer.cornerRadius = 22
//        self.loginButton.layer.shadowOpacity = 0.25
//        self.loginButton.layer.shadowOffset = CGSize(width: 0, height: 10)
//        self.loginButton.layer.shadowRadius = 14
//            self.self.loginButton.isHidden = false
//            
//    
//        
//        
//        loginButton.delegate = self as! FBSDKLoginButtonDelegate

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
    @IBAction private func emailBeginEditing(_ sender: TweeAttributedTextField) {
        emailTextField.hideInfo()
    }
    
    @IBAction private func emailEndEditing(_ sender: TweeAttributedTextField) {
        if let emailText = sender.text, emailText.isValidEmail1 == true {
            return
        }
        
        sender.showInfo("Email address is incorrect. Check it out")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if isOverCurrentContextTransition {
            segue.destination.setCustomModalTransition(customModalTransition: AlphaByStepTransition(), inPresentationStyle: .overCurrentContext)
        } else {
            segue.destination.customModalTransition = FashionTransition()
        }
    }
    
    @IBOutlet weak var showButton: UIButton! {
        didSet {
            showButton.underlineCurrentTitle()
        }
    }

    @IBAction func SignInButton(_ sender: Any) {
        SignInButton.startAnimation() // 2: Then start the animation when the user tap the button
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            sleep(3)
            let HeadersParameters = ["Accept":"application/json"]
            let bodyParams = ["email":self.emailTextField.text,"password":self.PasswordTextField.text] as [String : Any]
            Alamofire.request(LoginPasswordAPI  , method: .post, parameters: bodyParams, encoding: JSONEncoding.default, headers: HeadersParameters).responseJSON(completionHandler: { (response) in
                print(response.result.value)
                let json = JSON(response.result.value)
                let Refresh_Token = json["refresh_token"].string
                self.appdelegate.LoginAPI_RefreshToken = Refresh_Token
                let context =   self.appdelegate.persistentContainer.viewContext
                
              let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
                let newUser = NSManagedObject(entity: entity!, insertInto: context)
                newUser.setValue(self.emailTextField.text!, forKey: "email")
                newUser.setValue(self.PasswordTextField.text!, forKey: "password")
                newUser.setValue(self.PasswordTextField.text!, forKey: "refreshtoken")
               
                do {
                    try context.save()
                } catch {
                    print("Failed saving")
                }
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
                //request.predicate = NSPredicate(format: "age = %@", "12")
                request.returnsObjectsAsFaults = false
                do {
                    let result = try context.fetch(request)
                    for data in result as! [NSManagedObject] {
                        print(data.value(forKey: "email") as! String)
                        print(data.value(forKey: "password") as! String)
                    }
                    
                } catch {
                    
                    print("Failed")
                }
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "homeview")
                
                self.present(controller!, animated: true, completion: nil)
            })// 3: Do your networking task or background work here.
        
            DispatchQueue.main.async(execute: { () -> Void in
                // 4: Stop the animation, here you have three options for the `animationStyle` property:
                // .expand: useful when the task has been compeletd successfully and you want to expand the button and transit to another view controller in the completion callback
                // .shake: when you want to reflect to the user that the task did not complete successfly
                // .normal
                self.SignInButton.stopAnimation(animationStyle: .expand, completion:
                    {
                      
                    print("harris")
                })
            })
        })
    }
}




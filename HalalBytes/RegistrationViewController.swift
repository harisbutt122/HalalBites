//
//  RegistrationViewController.swift
//  HalalBytes
//
//  Created by harisbutt on 8/6/18.
//  Copyright © 2018 Ammar Waheed. All rights reserved.
//

import UIKit
import TransitionButton
import Alamofire
import PMAlertController
class RegistrationViewController: UIViewController {

    @IBOutlet weak var RegisterButton: TransitionButton!
    
    @IBOutlet weak var Email: TJTextField!
    @IBOutlet weak var Name: TJTextField!
    @IBOutlet weak var Password: TJTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func Register(_ sender: Any) {
       RegisterButton.startAnimation() // 2: Then start the animation when the user tap the button
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            sleep(3) // 3: Do your networking task or background work here.
            
            DispatchQueue.main.async(execute: { () -> Void in
                // 4: Stop the animation, here you have three options for the `animationStyle` property:
                // .expand: useful when the task has been compeletd successfully and you want to expand the button and transit to another view controller in the completion callback
                // .shake: when you want to reflect to the user that the task did not complete successfly
                // .normal
                self.RegisterButton.stopAnimation(animationStyle: .shake, completion: {
                    let HeadersParameters = ["Accept":"application/json"]
                    let bodyParams = ["name":self.Name.text!,"email":self.Email.text!,"password":self.Password.text!] as [String : Any]
                    Alamofire.request(RegisterAPI, method: .post, parameters: bodyParams, encoding: JSONEncoding.default, headers: HeadersParameters).responseJSON(completionHandler: { (response) in
                         print(response.result.value)
                        let json = JSON(response.result.value)
                        let messege = json["message"].string
                        print(messege)
                        if messege == "User has been registered. Please check your email in order to verify your email address."{
                            
                            
                            
                            let alertVC = PMAlertController(title: "" , description: messege! as! String, image:UIImage(named: "halal"), style: .alert)
                            
                            
                            
                            alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                               
                                let controller = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
                            
                                self.present(controller, animated: true, completion: nil)
                                print("Capture action OK")
                            }))
                            
                            
                            
                            self.present(alertVC, animated: true, completion: nil)
                        }else {
                            
                            let alertVC = PMAlertController(title: "" , description: messege! as! String, image:UIImage(named: "halal"), style: .alert)
                            
                            
                            
                            alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                                print("Capture action OK")
                            }))
                            
                            
                            
                            self.present(alertVC, animated: true, completion: nil)
                            
                        }
                      
                       
                    })
                   print("harris")
                })
            })
        })

    }
    
    
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.underlineCurrentTitle()
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    

}

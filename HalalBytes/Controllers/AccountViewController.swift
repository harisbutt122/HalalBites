//
//  AccountViewController.swift
//  HalalBytes
//
//  Created by Ammar Waheed on 22/04/2018.
//  Copyright © 2018 Ammar Waheed. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import CoreData

class AccountViewController: UIViewController {

    @IBOutlet weak var LogoutButton: UIView!
let appdelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func Logout(_ sender: Any) {
//        do {
//         let alert = UIAlertController(title: "Logout", message: "Are You Sure", preferredStyle: .actionSheet)
//            let logout = UIAlertAction(title: "Logout", style: .destructive) { (action) in
//
//                FBSDKAccessToken.setCurrent(nil)
//                self.appdelegate.RestaurantsDetails_Array.removeAll()
//                self.appdelegate.RestaurantsHours_Array.removeAll()
//                self.appdelegate.HoursAPIArray.removeAll()
//                self.appdelegate.ids.removeAll()
//                let uistoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                uistoryboard.instantiateInitialViewController()
//                let loginviewcontroller :UIViewController = uistoryboard.instantiateViewController(withIdentifier: "loginView")
//self.present(loginviewcontroller, animated: true, completion: nil)
//            }
//            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            alert.addAction(logout)
//            alert.addAction(cancel)
//            self.present(alert, animated: true, completion: nil)
//
//        } catch let signOutError as NSError {
//            print ("Error signing out: %@", signOutError)
//        }
        
        
        let alert = UIAlertController(title: "Logout", message: "Are You Sure", preferredStyle: .actionSheet)
                    let logout = UIAlertAction(title: "Logout", style: .destructive) { (action) in
        
                        FBSDKAccessToken.setCurrent(nil)
                        self.appdelegate.RestaurantsDetails_Array.removeAll()
                        self.appdelegate.RestaurantsHours_Array.removeAll()
                        self.appdelegate.HoursAPIArray.removeAll()
                        self.appdelegate.ids.removeAll()
                        self.appdelegate.LoginAppID = 2
                        let delegate = UIApplication.shared.delegate as! AppDelegate
                        let context = delegate.persistentContainer.viewContext
                        
                        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                        
                        do {
                            try context.execute(deleteRequest)
                            
                            try context.save()
                            print("delete")
                        } catch {
                            print ("There was an error")
                        }
//                        let context =   self.appdelegate.persistentContainer.viewContext
//
//                        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
//                        let newUser = NSManagedObject(entity: entity!, insertInto: context)
//
//
//
//                        context.delete(newUser)
//                        print("deleted")
//
//
//                        do {
//                            try context.save()
//                        } catch let error as NSError {
//                            print("Error While Deleting Note: \(error.userInfo)")
//                        }
                        let uistoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        uistoryboard.instantiateInitialViewController()
                        let loginviewcontroller :UIViewController = uistoryboard.instantiateViewController(withIdentifier: "loginView")
        self.present(loginviewcontroller, animated: true, completion: nil)
                    }
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(logout)
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
       
    
    }
    
    @IBAction func PrivacyAndPolicy(_ sender: Any) {
        if let url = NSURL(string: "https://www.halalbites.org/privacy-policy"){
            UIApplication.shared.openURL(url as URL)
        }
    }
    @IBAction func TermsAndConditions(_ sender: Any) {
        if let url = NSURL(string: "https://www.halalbites.org/terms-conditions"){
            UIApplication.shared.openURL(url as URL)
        }
    }
   
}



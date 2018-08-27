//
//  RestaurantsDetailsViewController.swift
//  HalalBytes
//
//  Created by Harris Butt on 6/12/18.
//  Copyright © 2018 Ammar Waheed. All rights reserved.
//

import UIKit
import Alamofire
class RestaurantsDetailsViewController: UIViewController {
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var ImageView: UIImageView!
    @IBOutlet var HalalnessLevel: UILabel!
    @IBOutlet var PhoneNumber: UILabel!
    @IBOutlet var Cusines: UILabel!
    @IBOutlet var Address: UILabel!
    @IBOutlet var Name: UILabel!
    @IBOutlet weak var OpenClose: UILabel!
    @IBOutlet weak var OpeningHours: UILabel!
    @IBOutlet weak var Imagethree: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(self.appdelegate.RestaurantsDetails_Array[appdelegate.didselect_Number])
showDetailsOfSingleRestaurant()
    }
    @IBOutlet weak var ImageTwo: UIImageView!
    
    func showDetailsOfSingleRestaurant(){
        var cusineName:String!
        let SingleRestaurant = self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number]
        self.Name.text = SingleRestaurant.Name
        self.Address.text = SingleRestaurant.Address
       
       if self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].OpenClose == true {
            self.OpenClose.textColor = .green
            self.OpenClose.text = "Open Now"
        }else {
            self.OpenClose.textColor = .red
            self.OpenClose.text = "Closed"
        }
        if SingleRestaurant.Cusine.count > 1{
            self.Cusines.text = "\(SingleRestaurant.Cusine[0]["name"].string!), \(SingleRestaurant.Cusine[1]["name"].string!)"
            
            
        }else {
             self.Cusines.text = "\(SingleRestaurant.Cusine[0]["name"].string!)"
            
        }
//      
        self.PhoneNumber.text = SingleRestaurant.PhoneNumber
        if SingleRestaurant.halalnessLevel == ""{
            self.HalalnessLevel.text = "N/A"
            
            
        }else{
            
             self.HalalnessLevel.text = SingleRestaurant.halalnessLevel
        }
       
        
        let remoteImageURL = URL(string: "https://halalbites.org/\(SingleRestaurant.ImageURL!)")!
        print(remoteImageURL)
//         Use Alamofire to download the image
        Alamofire.request(remoteImageURL).responseData { (response) in
            if response.error == nil {
                print(response.result)

                if let data = response.data {
                    self.ImageView.image = UIImage(data: data)
//                    self.ImageTwo.image = UIImage(data: data)
                     self.Imagethree.image = UIImage(data: data)
                }
            }
        }
        if self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].weekday_text.isEmpty == true{
            
            self.OpeningHours.text = "Working Hours is not Available"
            
        }else {
            
              self.OpeningHours.text = "\(self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].weekday_text![0])\n\(self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].weekday_text![1])\n\(self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].weekday_text![2])\n\(self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].weekday_text![3])\n\(self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].weekday_text![4])\n\(self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].weekday_text![5])"
            
        }
      

    }

    @IBAction func Map(_ sender: Any) {
        openGoogleMaps()
    }
    func openGoogleMaps() {
//        if let aString = URL(string: "comgooglemaps://") {
//            if UIApplication.shared.canOpenURL(aString) {
//                var temp = "comgooglemaps://?saddr=Google+Inc,+8th+Avenue,+New+York,+NY&daddr=John+F.+Kennedy+International+Airport,+Van+Wyck+Expressway,+Jamaica,+New+York&directionsmode=transit"
//                if let aTemp = URL(string: temp) {
//                    UIApplication.shared.openURL(aTemp)
//                }
//            } else {
//                print("Can't use comgooglemaps://")
//            }
//        }
//        //
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let urlString = String(format: "comgooglemaps://?q=\(self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].latitude!),\(self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].longitude!)&zoom=16&views=traffic&mapmode=standard")

//            let urlString = String(format: "comgooglemaps://?q=%f,%f&center=%f,%f&zoom=14",self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].latitude, self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].longitude, self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].latitude, self.appdelegate.RestaurantsDetails_Array[self.appdelegate.didselect_Number].longitude)
            UIApplication.shared.openURL(NSURL(string: urlString)! as URL)
        } else {
            let alert = UIAlertController(title: "Error", message: "Install Google Maps Application into your device", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
            print("Can't use comgooglemaps://")
        }



        
    }
}

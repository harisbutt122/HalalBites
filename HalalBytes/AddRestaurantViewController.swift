//
//  AddRestaurantViewController.swift
//  HalalBytes
//
//  Created by Ammar Waheed on 29/04/2018.
//  Copyright © 2018 Ammar Waheed. All rights reserved.
//

import UIKit
import TCPickerView
import Alamofire
import SVProgressHUD
protocol Toggleable
{
    mutating func toggle()
   
}

enum Status_On_Off: Toggleable
{
   
    
    case on, off
    
    mutating func toggle()
    {
        switch self
        {
        case .off:  self = Status_On_Off.on
        case .on:   self = Status_On_Off.off
        }
    }
    
    
    
}


class AddRestaurantViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, TCPickerViewOutput {

    @IBOutlet weak var PlusMinusButton: UIButton!
    @IBOutlet weak var TakePictureOLet: UIButton!
    

    @IBOutlet weak var Restaurant_AdditionalInformation: UITextField!
    @IBOutlet weak var Restaurant_Address: UITextField!
    @IBOutlet weak var Restaurant_Suburb: UITextField!
    @IBOutlet weak var picker_cuisine: UILabel!
    
    @IBOutlet weak var Restaurant_Name: UITextField!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var details_view: UIView!
    
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var array1 = [GetSelectedCuisines_IDs]()
     var statusOfSwitch = Status_On_Off.off


    var image:UIImage!
    let picker = UIPickerView()
    let ImagePickerController = UIImagePickerController()
    var CuisinesArray = [String]()
    var selectedCuisines = [String]()
    var selectedCusines_indexes = [Int]()
    var boolvalues = [Bool]()
    var JSONArray = [[String:Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.heightAnchor.constraint(equalToConstant:1300).isActive = true
        self.scrollView.heightAnchor.constraint(equalToConstant: 1300).isActive = true
        
        print(self.appdelegate.RefreshTokenAPI_AccessToken)
     
//        self.picker.delegate = self
//        self.picker.dataSource = self
    
        self.ImagePickerController.delegate = self
        Alamofire.request(CusinesAPI).responseJSON { (response) in
            
            let Data = JSON(response.result.value)
            let Cuisines = Data["cuisines"].arrayValue
            for CusinesNames in Cuisines{
                let Name = CusinesNames["name"].string
                print(Name!)
                self.CuisinesArray.append(Name!)
                
            }
           print(self.CuisinesArray.count)
        }
      

    }
    
    @IBAction func plusMinusBUtton(_ sender: UIButton) {
        statusOfSwitch.toggle()
        
        switch statusOfSwitch
        {
        case .on:
            
            
            sender.setImage(#imageLiteral(resourceName: "dissolve 3"), for: .normal)
            print("Plus")
            self.details_view.isHidden = false
            
             self.scrollView.heightAnchor.constraint(equalToConstant: 1212).isActive = true
            self.mainView.heightAnchor.constraint(equalToConstant: 1212).isActive = true
          self.details_view.heightAnchor.constraint(equalToConstant: 1500).isActive = true
            
            
        case .off:
            sender.setImage(#imageLiteral(resourceName: "expand 3"), for: .normal)
            self.details_view.isHidden = true
      
            
            print("Minus")
        }
    }


    
    
    @IBAction func dismissController(_ sender: Any) {
        if self.Restaurant_Name.text?.isEmpty == true{
            let alert = UIAlertController(title: "Oops", message: "Please enter the restaurant name", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
            
            
        }else if self.selectedCuisines.isEmpty == true {
            
            let alert = UIAlertController(title: "Oops", message: "You need to select atleast on cuisine", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
            
            
        }else if self.Restaurant_Suburb.text?.isEmpty == true {
            
            let alert = UIAlertController(title: "Oops", message: "Please enter the suburb", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
        }else {
            SVProgressHUD.show(withStatus: "Biting")
            
            
            
            let phoneNumbersDictionary = self.array1.map({ ["id": $0.ID!,"name":$0.Cuisines!] })
            
            print(phoneNumbersDictionary)
            let Data:String!
            let JSON = try? JSONSerialization.data(withJSONObject: phoneNumbersDictionary, options: [])
            if let JSON = JSON {
                print(String(data: JSON, encoding: String.Encoding.utf8)!)
            }
            
            
            
            let url = AddRestaurantsAPI
            let HeadersParameters = ["Accept":"application/json","Authorization":"Bearer \(self.appdelegate.RefreshTokenAPI_AccessToken!)"]
            let values = ["name":self.Restaurant_Name.text!,"address":self.Restaurant_Address.text!,"cuisines":String(data: JSON!, encoding: String.Encoding.utf8)!,"suburb":self.Restaurant_Suburb.text!,"additional_information":self.Restaurant_AdditionalInformation.text!,"user_id":self.appdelegate.User_ID] as [String : Any]
                        Alamofire.request(url, method: .post, parameters: values, encoding: JSONEncoding.default, headers:
                HeadersParameters).responseJSON(completionHandler:
                    { response in
                        switch response.result {
                        case .failure(let error):
                            SVProgressHUD.dismiss()
                            print(error)
                            let alert = UIAlertController(title: "Error", message: "Internet Connection Has been Lost", preferredStyle: .alert)
                            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                            alert.addAction(okay)
                            self.present(alert, animated: true, completion: nil)
                            if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                                print(responseString)
                            }
                        case .success(let responseObject):
                            print(responseObject)
                        
                            SVProgressHUD.showSuccess(withStatus: " Successfully Requested \n Thank you for sending us a tip. The submission is being reviewed by our team.")
                            SVProgressHUD.dismiss(withDelay: 1.0)
                            
                            self.dismiss(animated: true, completion: nil)
                            print("Success")
                        }
                })
            
            
            
            
        }
     


        
    }
    

   
    
 
  
  
  
    
    @IBAction func cusinesPicker(_ sender: UIButton) {
        
        self.selectedCuisines.removeAll()
        self.selectedCusines_indexes.removeAll()
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        let width: CGFloat = screenWidth - 64
        let height: CGFloat = screenHeight - 160
        var picker: TCPickerViewInput = TCPickerView(size: CGSize(width: width, height: height))
        picker.title = "Cuisines"
     
        let values = self.CuisinesArray.map { TCPickerView.Value(title: $0) }
        picker.values = values
        
        picker.delegate = self
        picker.cornerRadius = 20.0
        picker.itemsFont = UIFont.systemFont(ofSize: 15, weight: .bold)
        picker.mainColor = .lightGray
        picker.textColor = .white
        picker.closeButtonColor = .black
        picker.background = .gray
        picker.selection = .multiply
        picker.register(UINib(nibName: "ExampleTableViewCell", bundle: nil), forCellReuseIdentifier: "ExampleTableViewCell")
        picker.completion = { (selectedIndexes) in
            for i in selectedIndexes{
//                print(values[i].title)
        
                self.selectedCuisines.append(values[i].title)
        
                
            }
            
            print(self.selectedCuisines)
            print(self.boolvalues)
            print(self.selectedCusines_indexes)
            print(self.array1)
            for indexes in self.array1{
                let dic = ["id":indexes.ID!,"name":indexes.Cuisines!] as [String : Any]
                self.JSONArray.append(dic)
                
               

                
            }
           
                if self.selectedCuisines.count == 1{
                    
                     self.picker_cuisine.text = "\(self.selectedCuisines[0])"
                    
                }else if self.selectedCuisines.count == 2 {
                    
                      self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) "
                    
                }
                else if self.selectedCuisines.count == 3 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  "
                    
                }
                else if self.selectedCuisines.count == 4 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) "
                    
                }
                else if self.selectedCuisines.count == 5 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) "
                    
                } else if self.selectedCuisines.count == 6 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5])"
                    
                }else if self.selectedCuisines.count == 7 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6])"
                    
                }else if self.selectedCuisines.count == 8 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7])"
                    
                }else if self.selectedCuisines.count == 9 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[8])"
                    
                }
                else if self.selectedCuisines.count == 10 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9])"
                    
                }
                else if self.selectedCuisines.count == 11 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])"
                    
                }
                else if self.selectedCuisines.count == 12 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11])"
                    
                }
                else if self.selectedCuisines.count == 13 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12])"
                    
                }else if self.selectedCuisines.count == 14 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13])"
                    
                }else if self.selectedCuisines.count == 15 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14])"
                    
                }
                else if self.selectedCuisines.count == 16 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15])"
                    
                }
                else if self.selectedCuisines.count == 17 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16])"
                    
                }  else if self.selectedCuisines.count == 18 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16]) , \(self.selectedCuisines[17])"
                    
                }else if self.selectedCuisines.count == 19 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16]) , \(self.selectedCuisines[17]) , \(self.selectedCuisines[18])"
                    
                }else if self.selectedCuisines.count == 20 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16]) , \(self.selectedCuisines[17]) , \(self.selectedCuisines[18]) , \(self.selectedCuisines[19])"
                    
                }else if self.selectedCuisines.count == 21 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16]) , \(self.selectedCuisines[17]) , \(self.selectedCuisines[18]) , \(self.selectedCuisines[19]) , \(self.selectedCuisines[20])"
                    
                }else if self.selectedCuisines.count == 22 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16]) , \(self.selectedCuisines[17]) , \(self.selectedCuisines[18]) , \(self.selectedCuisines[19]) , \(self.selectedCuisines[20]) , \(self.selectedCuisines[21])"
                    
                }else if self.selectedCuisines.count == 23 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16]) , \(self.selectedCuisines[17]) , \(self.selectedCuisines[18]) , \(self.selectedCuisines[19]) , \(self.selectedCuisines[20]) , \(self.selectedCuisines[21])) , \(self.selectedCuisines[22])"
                    
                }else if self.selectedCuisines.count == 24 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16]) , \(self.selectedCuisines[17]) , \(self.selectedCuisines[18]) , \(self.selectedCuisines[19]) , \(self.selectedCuisines[20]) , \(self.selectedCuisines[21])) , \(self.selectedCuisines[22]) , \(self.selectedCuisines[23])"
                    
                }else if self.selectedCuisines.count == 25 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16]) , \(self.selectedCuisines[17]) , \(self.selectedCuisines[18]) , \(self.selectedCuisines[19]) , \(self.selectedCuisines[20]) , \(self.selectedCuisines[21])) , \(self.selectedCuisines[22]) , \(self.selectedCuisines[23]) , \(self.selectedCuisines[24])"
                    
                }else if self.selectedCuisines.count == 26 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16]) , \(self.selectedCuisines[17]) , \(self.selectedCuisines[18]) , \(self.selectedCuisines[19]) , \(self.selectedCuisines[20]) , \(self.selectedCuisines[21])) , \(self.selectedCuisines[22]) , \(self.selectedCuisines[23]) , \(self.selectedCuisines[24]) , \(self.selectedCuisines[25])"
                    
                }else if self.selectedCuisines.count == 27 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16]) , \(self.selectedCuisines[17]) , \(self.selectedCuisines[18]) , \(self.selectedCuisines[19]) , \(self.selectedCuisines[20]) , \(self.selectedCuisines[21])) , \(self.selectedCuisines[22]) , \(self.selectedCuisines[23]) , \(self.selectedCuisines[24]) , \(self.selectedCuisines[25]) , \(self.selectedCuisines[26])"
                    
                }
                else if self.selectedCuisines.count == 28 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16]) , \(self.selectedCuisines[17]) , \(self.selectedCuisines[18]) , \(self.selectedCuisines[19]) , \(self.selectedCuisines[20]) , \(self.selectedCuisines[21])) , \(self.selectedCuisines[22]) , \(self.selectedCuisines[23]) , \(self.selectedCuisines[24]) , \(self.selectedCuisines[25]) , \(self.selectedCuisines[26]) , \(self.selectedCuisines[27])"
                    
                } else if self.selectedCuisines.count == 29 {
                    
                    self.picker_cuisine.text = "\(self.selectedCuisines[0]) , \(self.selectedCuisines[1]) , \(self.selectedCuisines[2])  , \(self.selectedCuisines[3]) , \(self.selectedCuisines[4]) , \(self.selectedCuisines[5]) , \(self.selectedCuisines[6]) , \(self.selectedCuisines[7]) , \(self.selectedCuisines[9]) , \(self.selectedCuisines[10])  , \(self.selectedCuisines[11]) , \(self.selectedCuisines[12]) , \(self.selectedCuisines[13]) , \(self.selectedCuisines[14]) , \(self.selectedCuisines[15]) , \(self.selectedCuisines[16]) , \(self.selectedCuisines[17]) , \(self.selectedCuisines[18]) , \(self.selectedCuisines[19]) , \(self.selectedCuisines[20]) , \(self.selectedCuisines[21])) , \(self.selectedCuisines[22]) , \(self.selectedCuisines[23]) , \(self.selectedCuisines[24]) , \(self.selectedCuisines[25]) , \(self.selectedCuisines[26]) , \(self.selectedCuisines[27]) , \(self.selectedCuisines[28])"
                    
                }
                
            
        }
        picker.show()
      
        
    }
    
    func pickerView(_ pickerView: TCPickerViewInput, didSelectRowAtIndex index: Int) {
        print("Uuser select row at index: \(index+1)")
//        self.selectedCusines_indexes.append(index+1)
        var aikob = GetSelectedCuisines_IDs(Cuisines: CuisinesArray[index], ID: index+1)
        self.array1.append(aikob)
        print(array1)
       
    }
    
    func pickerView(_ pickerView: TCPickerViewInput,
                    cellForRowAt indexPath: IndexPath) -> (UITableViewCell & TCPickerCellType)? {
        let cell = pickerView.dequeueReusableCell(withIdentifier: "ExampleTableViewCell", for: indexPath)
        return cell
    }

    @IBAction func Cancel(_ sender:AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
}


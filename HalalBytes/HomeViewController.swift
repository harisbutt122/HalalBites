//
//  HomeViewController.swift
//  HalalBytes
//
//  Created by Ammar Waheed on 22/04/2018.
//  Copyright © 2018 Ammar Waheed. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Alamofire
import SVProgressHUD
import BubbleTransition
import MapKit
import PMAlertController

class HomeViewController: UIViewController,UISearchControllerDelegate, UISearchBarDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var TableView: UITableView!
    
    @IBOutlet weak var Profile_Name: UILabel!
    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var transitionButton: UIButton!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var CollectionVIew: UICollectionView!
    var Name:String!
    var Email:String!
    var url:String!
   var CuisinesArray = [String]()
    var Cuisines_ID = [Int]()
    var apiCalls = 0
    var distancValue = [String]()
    
    var RestaurantsImages_Array = [String]()
    var HoursAPICount = 0
     var refresher: UIRefreshControl!
    var filtered:[restaurantsDetails] = []
    var NameArray = [String]()
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
let appdelegate = UIApplication.shared.delegate as! AppDelegate
      let transition = BubbleTransition()
    var locationManager = CLLocationManager()
    var searchString:String!
    var myLocation:CLLocationCoordinate2D?
    @IBOutlet weak var restaurantCollectionView: UICollectionView!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
    
        let pi = 3.14159
        
        let text = String(format: "%.0f", arguments: [pi])
        
        print(text)
        print(self.appdelegate.Current_Latitude)
        print(self.appdelegate.current_Longitude)
        print("\(HomeDataAPI)/5/5/\(self.appdelegate.Current_Latitude)/\(self.appdelegate.current_Longitude)/20")
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(HomeViewController.populate), for: UIControlEvents.valueChanged)
        CollectionVIew.addSubview(refresher)
        self.CollectionVIew.delegate = self
        self.CollectionVIew.dataSource = self
        self.TableView.delegate = self
        self.TableView.dataSource = self
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Restaurants"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true
//searchController.isActive = false
        Cuisines()
   FacebookGraphRequest()
        

    }
 
    func Cuisines(){
        
        Alamofire.request(CusinesAPI).responseJSON { (response) in
            
            let Data = JSON(response.result.value)
            let Cuisines = Data["cuisines"].arrayValue
            for CusinesNames in Cuisines{
                let Name = CusinesNames["name"].string
                let ids = CusinesNames["id"].number
                print(Name!)
                
                self.CuisinesArray.append(Name!)
                self.Cuisines_ID.append(ids as! Int)
               
            }
             self.TableView.reloadData()
            print(self.CuisinesArray.count)
            print(self.Cuisines_ID)
            
        }
        
        
    }
    func FacebookGraphRequest(){
        
        SVProgressHUD.show(withStatus: "Biting")
        let userID = FBSDKAccessToken.current().userID
        var request = FBSDKGraphRequest(graphPath:userID , parameters:["fields":"email,name,picture"] , httpMethod: "GET")
        
        
        
        request?.start(completionHandler: { connection, result, error in
            
           
            
            if(error == nil)
            {
                //                guard let UserCred = result as? [String:Any] else {return}
                //               guard let UserName = UserCred["name"] as!
                //                print("result \(UserCred)")
                
                let json = JSON(result)
                
                
                let picture = json["picture"].dictionary
                print(json)
               
                let data = picture!["data"]?.dictionaryObject
                print(data)
                let url = data!["url"] as! String
                print(url)
                let remoteImageURL = URL(string: url)!
                print(remoteImageURL)
                // Use Alamofire to download the image
                Alamofire.request(remoteImageURL).responseData { (response) in
                    if response.error == nil {
                        print(response.result)
                        
                        if let data = response.data {
                            self.ProfilePicture.image = UIImage(data: data)
                            
                            
                        }
                    }
                }
                
                
//                print(picture)
//                guard let data = picture!["data"] as? [String:Any] else {return}
//
//                print(data)
                self.appdelegate.name = json["name"].string
                self.appdelegate.email = json["email"].string
                self.Profile_Name.text = self.appdelegate.name
                print()
                print(self.appdelegate.name)
                print(self.appdelegate.email)
                let dic = ["email":self.appdelegate.email,"name":self.appdelegate.name]
                
                let LoginAPI_URL = "\(LoginAPI)?email=\"\(self.appdelegate.email!)\"&name=\"\(self.appdelegate.name!)\""
                
                print(LoginAPI_URL)
                self.GetLoginAPI_FetchData(params: ["email":self.appdelegate.email!,"name":self.appdelegate.name!])
                
                
                //
                
                
            }
            else
            {
                let alert = UIAlertController(title: "Network Error", message: "The Internet connection appears to be offline.", preferredStyle: .alert)
                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
                SVProgressHUD.dismiss()
                self.CollectionVIew.reloadData()
                print("error \(error)")
            }
        })

        
    }
 
    @objc func populate()
    {
        self.appdelegate.RestaurantHours_Array2.removeAll()
//        self.appdelegate.RestaurantHours_Array2 = self.appdelegate.RestaurantsHours_Array
        self.appdelegate.RestaurantsDetails_Array.removeAll()
        self.appdelegate.ids.removeAll()
        self.appdelegate.RestaurantsHours_Array.removeAll()
        self.appdelegate.HoursAPIArray.removeAll()
        self.filtered.removeAll()
        
        SVProgressHUD.show(withStatus: "Biting")
        FacebookGraphRequest()
        self.searchController.searchBar.text  = ""
        self.searchActive = false
//          self.GetLoginAPI_FetchData(params: ["email":self.appdelegate.email!,"name":self.appdelegate.name!])

        CollectionVIew.reloadData()
        refresher.endRefreshing()
    }

   

    func GetLoginAPI_FetchData(params: [String:String]) {
        
        let urlComp = NSURLComponents(string: LoginAPI)!
        
        var items = [URLQueryItem]()
        
        for (key,value) in params {
            items.append(URLQueryItem(name: key, value: value))
        }
        
        items = items.filter{!$0.name.isEmpty}
        
        if !items.isEmpty {
            urlComp.queryItems = items
        }
        
        var urlRequest = URLRequest(url: urlComp.url!)
        urlRequest.httpMethod = "POST"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //                    print("responseString = \(responseString)")
            
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    
                    // Print out dictionary
                    
                    let Refresh_Token = convertedJsonIntoDict["refresh_token"] as! String
                    let User_ID = convertedJsonIntoDict["user_id"] as! Int
                    
                   self.appdelegate.LoginAPI_RefreshToken = Refresh_Token
                    self.appdelegate.User_ID = User_ID
                    print(User_ID)
                    self.GetRefreshTokenAPI_FetchData(params: ["refresh_token":self.appdelegate.LoginAPI_RefreshToken!])
                    
                    
                }
            } catch let error as NSError {
                let alert = UIAlertController(title: "Network Error", message: "The Internet connection appears to be offline.", preferredStyle: .alert)
                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
                   SVProgressHUD.dismiss()
                 self.CollectionVIew.reloadData()
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func GetRefreshTokenAPI_FetchData(params: [String:String]) {
      
        let urlComp = NSURLComponents(string: RefreshTokenAPI)!
        
        var items = [URLQueryItem]()
        
        for (key,value) in params {
            items.append(URLQueryItem(name: key, value: value))
        }
        
        items = items.filter{!$0.name.isEmpty}
        
        if !items.isEmpty {
            urlComp.queryItems = items
        }
        
        var urlRequest = URLRequest(url: urlComp.url!)
        urlRequest.httpMethod = "POST"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //                    print("responseString = \(responseString)")
            
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    // Print out dictionary
                   
                    guard let access_Token = convertedJsonIntoDict["access_token"] as? String else{return}
                self.appdelegate.RefreshTokenAPI_AccessToken = access_Token
//                    print(access_Token)
                    let HeadersParameters = ["Accept":"application/json","Authorization":"Bearer \(self.appdelegate.RefreshTokenAPI_AccessToken!)"]
                   let url = "\(HomeDataAPI)/5/5/\(self.appdelegate.Current_Latitude!)/\(self.appdelegate.current_Longitude!)/20"
                    var RequestHomeData_API = try! URLRequest(url: url, method: HTTPMethod(rawValue: "GET")!, headers: HeadersParameters)
                 
                 
                    //                request1.httpMethod = "GET"
                    Alamofire.request(RequestHomeData_API).responseJSON(completionHandler: { (HomeDataAPI_REsponse) in
                   
                        let Distionary1 =  JSON(HomeDataAPI_REsponse.result.value)
                        let Restaurants = Distionary1["restaurants"]
                    let objects = Restaurants.arrayValue
//                        print(objects)
                        for RestaurantsDetails in objects{
                            let uid = RestaurantsDetails["id"].number
                           let name = RestaurantsDetails["name"].string
                            let cusines = RestaurantsDetails["cuisines"].arrayValue
                            let halalnesslevel = RestaurantsDetails["halalness_level"].string
                            let suburb = RestaurantsDetails["suburb"].string
                            let images = RestaurantsDetails["picture_path"].string
                            let phonenumber = RestaurantsDetails["phone_number"].string
                            let Address = RestaurantsDetails["location"].string
                            let latitude = RestaurantsDetails["latitude"].double
                            let longitude = RestaurantsDetails["longitude"].double
                            let distance = RestaurantsDetails["distance"].double
                            let Google_Data = JSON(RestaurantsDetails["google_data"])
                            guard let Rating = Google_Data["rating"].double else{return}
                            guard let OpenClose = Google_Data["open_now"].bool else{return}
                            print(Rating)
                                                            print(OpenClose)
                            print(Int(distance!))
                            guard  let Weekday_Text = Google_Data["weekday_text"].arrayObject else{return}
                            
                            self.RestaurantsImages_Array.append(images!)
                            self.appdelegate.ids.append(uid as! Int)
                        
                            let SingleRestaurantsDetails  = restaurantsDetails(ImageURL: images, Name: name, Cusine: cusines, halalnessLevel: halalnesslevel, suburb: suburb, distance: distance, PhoneNumber: phonenumber, Address: Address, latitude: latitude, longitude: longitude, rating: Rating, OpenClose: OpenClose, weekday_text: Weekday_Text)
                            
                            
                            self.appdelegate.RestaurantsDetails_Array.append(SingleRestaurantsDetails)
                            
                            self.appdelegate.RestaurantsDetails_Array.sort(by: { $0.distance < $1.distance })
                            
                            self.NameArray.append(name!)
                        
                       
//                            print(self.appdelegate.RestaurantsDetails_Array.count)
//                            print(cusines)
                            
                        }
                  
                        self.CollectionVIew.reloadData()
                        SVProgressHUD.dismiss()
                         print(self.RestaurantsImages_Array)
                        print(self.appdelegate.RestaurantsDetails_Array.count)

                      
                        print(self.appdelegate.ids)
//                        self.HourAPi()
                    })
                   
                   
                    
                }
                
            } catch let error as NSError {
                let alert = UIAlertController(title: "Network Error", message: "The Internet connection appears to be offline.", preferredStyle: .alert)
                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
                   SVProgressHUD.dismiss()
                 self.CollectionVIew.reloadData()
                print(error.localizedDescription)
            }
        })
        task.resume()
        print(self.appdelegate.RestaurantsDetails_Array)

    }
    

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.appdelegate.RestaurantHours_Array2.removeAll()
        //        self.appdelegate.RestaurantHours_Array2 = self.appdelegate.RestaurantsHours_Array
        self.appdelegate.RestaurantsDetails_Array.removeAll()
        self.appdelegate.ids.removeAll()
        self.appdelegate.RestaurantsHours_Array.removeAll()
        self.appdelegate.HoursAPIArray.removeAll()
        self.filtered.removeAll()
        self.TableView.isHidden = true
        FacebookGraphRequest()
//        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
       
        self.searchString = searchController.searchBar.text
      
        if searchString == ""{
            self.appdelegate.RestaurantHours_Array2.removeAll()
            //        self.appdelegate.RestaurantHours_Array2 = self.appdelegate.RestaurantsHours_Array
            self.appdelegate.RestaurantsDetails_Array.removeAll()
            self.appdelegate.ids.removeAll()
//            self.appdelegate.RestaurantsHours_Array.removeAll()
            self.appdelegate.HoursAPIArray.removeAll()
            self.filtered.removeAll()

            
        }else {
            self.TableView.isHidden = true
            SVProgressHUD.show(withStatus: "Biting")
            var BodyParameters = ["restaurant_name":searchString,"latitude":self.appdelegate.Current_Latitude,"longitude":self.appdelegate.current_Longitude] as [String : Any]
            let HeadersParameters = ["Accept":"application/json","Authorization":"Bearer \(self.appdelegate.RefreshTokenAPI_AccessToken!)"]
            
            Alamofire.request(SearchAPI, method: .post, parameters: BodyParameters, encoding: JSONEncoding.default, headers:
                HeadersParameters).responseJSON(completionHandler:
                    { response in
                        switch response.result {
                        case .failure(let error):
                            print(error)
                             let alert = UIAlertController(title: "Network Error", message: "The Internet connection appears to be offline.", preferredStyle: .alert)
                            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                            alert.addAction(okay)
                            self.present(alert, animated: true, completion: nil)
                            SVProgressHUD.dismiss()
                            if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                                print(responseString)
                            }
                        case .success(let responseObject):
                            
//                            print(responseObject)
                            self.appdelegate.RestaurantHours_Array2.removeAll()
                            //        self.appdelegate.RestaurantHours_Array2 = self.appdelegate.RestaurantsHours_Array
                            self.appdelegate.RestaurantsDetails_Array.removeAll()
                            self.appdelegate.ids.removeAll()
//                            self.appdelegate.RestaurantsHours_Array.removeAll()
//                            self.appdelegate.HoursAPIArray.removeAll()
                            let Distionary1 =  JSON(responseObject)
                            let Restaurants = Distionary1["restaurants"]
                            let objects = Restaurants.arrayValue
                            //                        print(objects)
                            for RestaurantsDetails in objects{
                                let uid = RestaurantsDetails["id"].number
                                let name = RestaurantsDetails["name"].string
                                let cusines = RestaurantsDetails["cuisines"].arrayValue
                                let halalnesslevel = RestaurantsDetails["halalness_level"].string
                                let suburb = RestaurantsDetails["suburb"].string
                                let images = RestaurantsDetails["picture_path"].string
                                let phonenumber = RestaurantsDetails["phone_number"].string
                                let Address = RestaurantsDetails["location"].string
                                let latitude = RestaurantsDetails["latitude"].double
                                let longitude = RestaurantsDetails["longitude"].double
                                let distance = RestaurantsDetails["distance"].double
                                let Google_Data = JSON(RestaurantsDetails["google_data"])
                                guard let Rating = Google_Data["rating"].double else{return}
                                guard let OpenClose = Google_Data["open_now"].bool else{return}
                                print(Rating)
                                print(OpenClose)
                                guard  let Weekday_Text = Google_Data["weekday_text"].arrayObject else{return}
                                
                                self.RestaurantsImages_Array.append(images!)
                                self.appdelegate.ids.append(uid as! Int)
                                let SingleRestaurantsDetails  = restaurantsDetails(ImageURL: images, Name: name, Cusine: cusines, halalnessLevel: halalnesslevel, suburb: suburb, distance: distance, PhoneNumber: phonenumber, Address: Address, latitude: latitude, longitude: longitude, rating: Rating, OpenClose: OpenClose, weekday_text: Weekday_Text)
                                
                                self.appdelegate.RestaurantsDetails_Array.append(SingleRestaurantsDetails)
                                self.NameArray.append(name!)
                                
                                
                                
                                
//                                                            print(self.appdelegate.RestaurantsDetails_Array.count)
//                                                            print(cusines)
                                
                            }
                            self.filtered = self.appdelegate.RestaurantsDetails_Array.filter({ (item) -> Bool in
                                        let countryText: NSString = item.Name as NSString

                                return (countryText.range(of: self.searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
                              
                                    })
                            print("Success")
                            print(self.filtered)
                             self.filtered.sort(by: { $0.distance < $1.distance })
                            if self.filtered.isEmpty == true{
                                let alert = UIAlertController(title: nil, message: "Sorry, But we did not find any restaurant for you.", preferredStyle: .alert)
                                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                                    self.searchActive = false
                                   self.searchController.searchBar.text = ""
                                    
                                    self.searchActive = true
                                   
                                    self.CollectionVIew.reloadData()
                                })
                                alert.addAction(okay)
                                self.present(alert, animated: true, completion: nil)
                               
                                SVProgressHUD.dismiss()
                           
                            
                            }else {
                                self.CollectionVIew.reloadData()
                                SVProgressHUD.dismiss()
                                
                            }
                            
                        }
                })
            
            
        }
       
        print("HalalBites")

        
      
      
      
       
        
       
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.TableView.isHidden = false
        searchActive = true
   self.searchController.searchBar.text = ""
       self.CollectionVIew.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
       
       CollectionVIew.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if !searchActive {
            searchActive = true
             self.CollectionVIew.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
  
    @IBAction func QrCodeScanner(_ sender: Any) {
        let vc = MGPScannerViewController.viewControllerFrom(storyboard: "Main", withIdentifier: "MGPScannerViewController")!
        vc.delegate = self
        vc.closeBarButtonDirection = .right
        vc.overlayColor = UIColor.yellow
        //        vc.closeBarButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(close))
        
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.tintColor = UIColor.white
        nav.navigationBar.barTintColor = UIColor.yellow
        present(nav, animated: true, completion: nil)
    }
    @objc func close() {
        navigationController?.popViewController(animated: true)
        //        self.dismiss(animated: true, completion: nil)
    }
    
}
extension HomeViewController:UICollectionViewDelegate,UICollectionViewDataSource, UISearchResultsUpdating, UIViewControllerTransitioningDelegate,UITableViewDelegate,UITableViewDataSource{
 
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        }
        else
        {
            return self.appdelegate.RestaurantsDetails_Array.count
        }
    }
    
        
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sectionCell", for: indexPath) as! RestaurantCollectionViewCell
        if searchActive{
            
            cell.Name.text = self.filtered[indexPath.row].Name
            if self.filtered[indexPath.row].Cusine.count > 1{
                cell.Cusine.text = "\(self.filtered[indexPath.row].Cusine[0]["name"].string!), \(self.filtered[indexPath.row].Cusine[1]["name"].string!)"
                
                
            }else {
                cell.Cusine.text = "\(self.filtered[indexPath.row].Cusine[0]["name"].string!)"
                
            }
            //        for CusineName in self.appdelegate.RestaurantsDetails_Array[indexPath.row].Cusine{
            //            name = CusineName["name"].string
            //        }
            
            if self.filtered[indexPath.row].halalnessLevel == ""{
                cell.HalalnessLevel.text = "N/A"
                
                
            }else{
                cell.HalalnessLevel.text = self.filtered[indexPath.row].halalnessLevel
            }
            
            cell.Suburb.text = self.filtered[indexPath.row].suburb
            //        cell.Rating.text = String(self.appdelegate.RestaurantsHours_Array[indexPath.row].rating!)
            
            
            let remoteImageURL = URL(string: "https://halalbites.org/\(self.filtered[indexPath.row].ImageURL!)")!
            print(remoteImageURL)
            // Use Alamofire to download the image
            Alamofire.request(remoteImageURL).responseData { (response) in
                if response.error == nil {
                    print(response.result)
                    
                    if let data = response.data {
                        cell.ImageView.image = UIImage(data: data)
                      
                    
                    }
                }
            }
            
                
                
                if self.filtered[indexPath.row].rating! == nil{
                    cell.Rating.text = ""
                    
                }else{
                    
                    cell.Rating.text = "\(self.filtered[indexPath.row].rating!)"
                }
                
                if self.filtered[indexPath.row].OpenClose! == true{
                    cell.OpenClose.textColor = .green
                    cell.OpenClose.text = "Open Now"
                    
                    
                }else {
                    cell.OpenClose.textColor = .red
                    cell.OpenClose.text = "Closed"
                    
                    
                }
            let text = String(format: "%.0f", arguments: [self.filtered[indexPath.row].distance])
            if text == "0"{
                let text1 = String(format: "%.1f", arguments: [self.filtered[indexPath.row].distance])
                cell.Distance.text = "\(text)km"
                
            }else {
                
                let text = String(format: "%.0f", arguments: [self.appdelegate.RestaurantsDetails_Array[indexPath.row].distance])
                cell.Distance.text = "\(text)km"
                
            }
            
//            cell.Distance.text = "\(self.filtered[indexPath.row].distance!)km"
            
        }else {
          cell.Name.text = self.appdelegate.RestaurantsDetails_Array[indexPath.row].Name
        if self.appdelegate.RestaurantsDetails_Array[indexPath.row].Cusine.count > 1{
            cell.Cusine.text = "\(self.appdelegate.RestaurantsDetails_Array[indexPath.row].Cusine[0]["name"].string!), \(self.appdelegate.RestaurantsDetails_Array[indexPath.row].Cusine[1]["name"].string!)"
            
            
        }else {
            cell.Cusine.text = "\(self.appdelegate.RestaurantsDetails_Array[indexPath.row].Cusine[0]["name"].string!)"
            
        }
        //        for CusineName in self.appdelegate.RestaurantsDetails_Array[indexPath.row].Cusine{
        //            name = CusineName["name"].string
        //        }
        
        if self.appdelegate.RestaurantsDetails_Array[indexPath.row].halalnessLevel == ""{
            cell.HalalnessLevel.text = "N/A"
            
            
        }else{
            cell.HalalnessLevel.text = self.appdelegate.RestaurantsDetails_Array[indexPath.row].halalnessLevel
        }
        
        cell.Suburb.text = self.appdelegate.RestaurantsDetails_Array[indexPath.row].suburb
//        cell.Rating.text = String(self.appdelegate.RestaurantsHours_Array[indexPath.row].rating!)
        

        let remoteImageURL = URL(string: "https://halalbites.org/\(self.appdelegate.RestaurantsDetails_Array[indexPath.row].ImageURL!)")!
        print(remoteImageURL)
        // Use Alamofire to download the image
        Alamofire.request(remoteImageURL).responseData { (response) in
            if response.error == nil {
                print(response.result)
                
                if let data = response.data {
                    cell.ImageView.image = UIImage(data: data)
                 
                }
            }
        }
        
            
            
            if self.appdelegate.RestaurantsDetails_Array[indexPath.row].rating! == nil{
                cell.Rating.text = ""
                
            }else{
                
                cell.Rating.text = "\(self.appdelegate.RestaurantsDetails_Array[indexPath.row].rating!)"
            }
            
            if self.appdelegate.RestaurantsDetails_Array[indexPath.row].OpenClose! == true{
                cell.OpenClose.textColor = .green
                cell.OpenClose.text = "Open Now"
                
                
            }else {
                cell.OpenClose.textColor = .red
                cell.OpenClose.text = "Closed"
                
                
            }
           
            
            let text = String(format: "%.0f", arguments: [self.appdelegate.RestaurantsDetails_Array[indexPath.row].distance])
            if text == "0"{
                 let text1 = String(format: "%.1f", arguments: [self.appdelegate.RestaurantsDetails_Array[indexPath.row].distance])
                 cell.Distance.text = "\(text)km"
                
            }else {
                
                let text = String(format: "%.0f", arguments: [self.appdelegate.RestaurantsDetails_Array[indexPath.row].distance])
                cell.Distance.text = "\(text)km"
                
            }
            print(text)
      
//        cell.Distance.text = "\(self.appdelegate.RestaurantsDetails_Array[indexPath.row].distance!)km"
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.appdelegate.didselect_Number = indexPath.row
        searchController.searchBar.resignFirstResponder()
        self.performSegue(withIdentifier: "Details", sender: self)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.CuisinesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cuisines") as! CusinesTableViewCell
        cell.Cuisines.text = self.CuisinesArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
          print(indexPath.row)
        searchController.searchBar.resignFirstResponder()
        SVProgressHUD.show(withStatus: "Biting")
        self.TableView.isHidden = true
        self.appdelegate.RestaurantHours_Array2.removeAll()
        //        self.appdelegate.RestaurantHours_Array2 = self.appdelegate.RestaurantsHours_Array
        self.appdelegate.RestaurantsDetails_Array.removeAll()
        self.appdelegate.ids.removeAll()
        //                            self.appdelegate.RestaurantsHours_Array.removeAll()
        //                            self.appdelegate.HoursAPIArray.removeAll()
            self.appdelegate.didselect_Number = indexPath.row
        self.searchActive = false
            var BodyParameters = ["cuisines":self.Cuisines_ID[indexPath.row],"latitude":self.appdelegate.Current_Latitude,"longitude":self.appdelegate.current_Longitude] as [String : Any]
            let HeadersParameters = ["Accept":"application/json","Authorization":"Bearer \(self.appdelegate.RefreshTokenAPI_AccessToken!)"]
            
            Alamofire.request(SearchAPI, method: .post, parameters: BodyParameters, encoding: JSONEncoding.default, headers:
                HeadersParameters).responseJSON { (response) in
                    switch response.result {
                    case .failure(let error):
                        print(error)
                        let alert = UIAlertController(title: "Error", message: "Internet Connection Has been Lost", preferredStyle: .alert)
                        let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                        alert.addAction(okay)
                        self.present(alert, animated: true, completion: nil)
                        SVProgressHUD.dismiss()
                        if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                            print(responseString)
                        }
                    case .success(let responseObject):
                    let Distionary1 =  JSON(responseObject)
                    print(Distionary1)
                    let Restaurants = Distionary1["restaurants"]
              
                    let objects = Restaurants.arrayValue
                    //                        print(objects)
                    for RestaurantsDetails in objects{
                        let uid = RestaurantsDetails["id"].number
                        let name = RestaurantsDetails["name"].string
                        let cusines = RestaurantsDetails["cuisines"].arrayValue
                        let halalnesslevel = RestaurantsDetails["halalness_level"].string
                        let suburb = RestaurantsDetails["suburb"].string
                        let images = RestaurantsDetails["picture_path"].string
                        let phonenumber = RestaurantsDetails["phone_number"].string
                        let Address = RestaurantsDetails["location"].string
                        let latitude = RestaurantsDetails["latitude"].double
                        let longitude = RestaurantsDetails["longitude"].double
                        let distance = RestaurantsDetails["distance"].double
                        let Google_Data = JSON(RestaurantsDetails["google_data"])
                        guard let Rating = Google_Data["rating"].double else{return}
                        guard let OpenClose = Google_Data["open_now"].bool else{return}
                        print(Rating)
                        print(OpenClose)
                        guard  let Weekday_Text = Google_Data["weekday_text"].arrayObject else{return}
                        
                        self.RestaurantsImages_Array.append(images!)
                        self.appdelegate.ids.append(uid as! Int)
                        let SingleRestaurantsDetails  = restaurantsDetails(ImageURL: images, Name: name, Cusine: cusines, halalnessLevel: halalnesslevel, suburb: suburb, distance: distance, PhoneNumber: phonenumber, Address: Address, latitude: latitude, longitude: longitude, rating: Rating, OpenClose: OpenClose, weekday_text: Weekday_Text)
                        
                        self.appdelegate.RestaurantsDetails_Array.append(SingleRestaurantsDetails)
                         self.appdelegate.RestaurantsDetails_Array.sort(by: { $0.distance < $1.distance })
                        self.NameArray.append(name!)
                        
                        
                        
                        
                        //                                                            print(self.appdelegate.RestaurantsDetails_Array.count)
                        //                                                            print(cusines)
                        
                    }
                    
                    print(self.appdelegate.RestaurantsDetails_Array)
                    SVProgressHUD.dismiss(completion: {
                        self.CollectionVIew.reloadData()
                     

                        
                    })
                    }
            }
            
        
            
            
            
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = transitionButton.center
        transition.bubbleColor = transitionButton.backgroundColor!
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = transitionButton.center
        transition.bubbleColor = transitionButton.backgroundColor!
        return transition
    }
    
}

extension HomeViewController: MGPScannerViewControllerDelegate {
    
    func barcodeDidScannedWith(text: String, OfType type: ScannedItem, error: ScanningError?) {
        
        if let error = error {
            showAlert(msg: error.msg)
            return
        }
        
        switch type {
        case .email:
            showAlert(msg: "Email : \(text)")
        case .link:
            showAlert(msg: "Link: \(text)")
        case .number:
            showAlert(msg: "Number: \(text)")
        case .text:
            showAlert(msg: "Text: \(text)")
        case .other:
            let HeadersParameters = ["Accept":"application/json","Authorization":"Bearer \(self.appdelegate.RefreshTokenAPI_AccessToken!)"]
            print(text)
            print(QrcodeAPI+text)
            let url = QrcodeAPI+text
            SVProgressHUD.show(withStatus: "Biting")
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: HeadersParameters).responseJSON { (response) in
                print(response.result.value)
                let Allvalues = JSON(response.result.value)
                let message = Allvalues["message"].string
                let deal_id = Allvalues["deal_id"].number
                print(message)
                if message == "deal_expired"{
                    let alertVC = PMAlertController(title: "", description: "We are sorry, but the deal has expired. Please contact the restaurant/cafe.", image:UIImage(named: "halal"), style: .alert)
                    
                    
                    
                    alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                        print("Capture action OK")
                    }))
                    
                    
                    
                    self.present(alertVC, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                    
                }else if message == "deal_code_not_found"{
                    let alertVC = PMAlertController(title: "", description: "We are sorry, we could not find the deal. Please contact the restaurant/cafe.", image:UIImage(named: "halal"), style: .alert)
                    
                    
                    
                    alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                        print("Capture action OK")
                    }))
                    
                    
                    
                    self.present(alertVC, animated: true, completion: nil)
                     SVProgressHUD.dismiss()
                    
                }else if message == "deal_not_given"{
                    
                    
                    let alertVC = PMAlertController(title: "", description: "We are sorry, but the deal could not be found. Please contact the restaurant/cafe.", image:UIImage(named: "halal"), style: .alert)
                    
                    
                    
                    alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                        print("Capture action OK")
                    }))
                    
                    
                    
                    self.present(alertVC, animated: true, completion: nil)
                    
                     SVProgressHUD.dismiss()
                }else {
                    let alertVC = PMAlertController(title: message!, description: message!, image:UIImage(named: "halal"), style: .alert)
                    
                    
                    alertVC.addAction(PMAlertAction(title: "CANCEL", style: .cancel, action: { () in
                        print("Capture action OK")
                    }))
                    alertVC.addAction(PMAlertAction(title: "CONFIRM", style: .default, action: { () in
                        SVProgressHUD.show(withStatus: "Biting")
                         let HeadersParameters = ["Accept":"application/json","Authorization":"Bearer \(self.appdelegate.RefreshTokenAPI_AccessToken!)"]
                        let bodyParams = ["user_id":self.appdelegate.User_ID,"deal_id":deal_id] as [String : Any]
                        Alamofire.request(ProcessAPI, method: .post, parameters: bodyParams, encoding: JSONEncoding.default, headers: HeadersParameters).responseJSON(completionHandler: { (response) in
                            print(response.result.value)
                            let Allvalues = JSON(response.result.value)
                            let message1 = Allvalues["message"].string
                            print(message1)
                            if message1 == "deal_already_consumed"{
                                
                                let alertVC = PMAlertController(title: "", description: "You have already consumed the deal.", image:UIImage(named: "halal"), style: .alert)
                                
                                
                                
                                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                                    print("Capture action OK")
                                }))
                                
                                
                                
                                self.present(alertVC, animated: true, completion: nil)
                                SVProgressHUD.dismiss()
                                
                            }else {
                                let alertVC = PMAlertController(title: message1!, description: "Your deal has been applied successfully. Please show this code to restaurant/cafe in order to avail the deal.", image:UIImage(named: "halal"), style: .alert)
                                
                                
                                
                                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                                    print("Capture action OK")
                                }))
                                
                                
                                
                                self.present(alertVC, animated: true, completion: nil)
                                SVProgressHUD.dismiss()
                                
                                
                            }
                        })
                        print("Capture action OK")
                    }))
                    
                    
                    
                    self.present(alertVC, animated: true, completion: nil)
                     SVProgressHUD.dismiss()
                    
                    
                }
               
            }
            
           
        }
        
    }
    
    //-----------------------------------------------------
    
    func barcodeDidScannedWith(error: ScanningError) {
        
        if error.code == .barCodeNotScanned {
            showAlert(msg: error.msg)
        } else if error.code == .cameraNotFound {
            showAlert(msg: error.msg)
        }
    }
    
    //-----------------------------------------------------
    
    func cameraPermission(error: ScanningError) {
        
        if error.code == .cameraPermissionNotGranted {
            showAlert(msg: "Please enable camera access from settings.")
        } else if error.code == .cameraPermissionRestricted {
            showAlert(msg: "Your device camera access is restricted.")
        } else if error.code == .camerePermissionNotDetermined {
            showAlert(msg: "Your device camera access can't be determined.")
        }
    }
    
    //-----------------------------------------------------
}


//-----------------------------------------------------

//MARK: - Alert Methods

//-----------------------------------------------------

extension HomeViewController {
    
    func showAlert(title: String?, msg: String?, actions: [UIAlertAction]?) {
        
        guard let arrayActions = actions else {
            debugPrint("There should be atleast one alert action.")
            return
        }
        
        let alertTitle = title ?? "Scanner Demo"
        let alertMsg = msg ?? ""
        
        let alertVC = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
        
        for action in arrayActions {
            alertVC.addAction(action)
        }
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    //-----------------------------------------------------
    
    func showAlert(msg: String) {
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        self.showAlert(title: nil, msg: msg, actions: [okAction])
    }
    
    //-----------------------------------------------------
    
    func showAlert(msg: String, actions: [UIAlertAction]?) {
        self.showAlert(title: nil, msg: msg, actions: actions)
    }
    
    //-----------------------------------------------------
    
}




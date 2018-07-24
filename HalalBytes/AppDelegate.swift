//
//  AppDelegate.swift
//  HalalBytes
//
//  Created by Ammar Waheed on 22/04/2018.
//  Copyright © 2018 Ammar Waheed. All rights reserved.
//

import UIKit
import FBSDKCoreKit

import SVProgressHUD
import Alamofire
import MapKit
import IQKeyboardManagerSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {

    var window: UIWindow?
    var name:String!
    var email:String!
    var LoginAPI_RefreshToken:String!
    var RefreshTokenAPI_AccessToken:String!
    
    var RestaurantsDetails_Array = [restaurantsDetails]()
     var RestaurantsHours_Array = [RatingOpenNow]()
    var RestaurantHours_Array2 = [RatingOpenNow]()
    var ids = [Int]()
    var didselect_Number:Int!
   
    var Current_Latitude:Double!
    var current_Longitude:Double!
    var User_ID:Int!
     var HoursAPIArray = [String]()
    var locationManager = CLLocationManager()
    
    var myLocation:CLLocationCoordinate2D?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        let twitterLogoBezierPath = SPBezierPathFigure.logos.logoTwitter()
//        SPLaunchAnimation.asTwitter(withIcon: twitterLogoBezierPath, onWindow: self.window!)
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
       
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        IQKeyboardManager.shared.enable = true
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        if FBSDKAccessToken.current() != nil{
            
            
            let uistoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            uistoryboard.instantiateInitialViewController()
            let homeviewcontroller :UIViewController = uistoryboard.instantiateViewController(withIdentifier: "homeview")
            if let windows = self.window{
                windows.rootViewController = homeviewcontroller
                
            }

        }
        
        return true
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation1 = locations.last
        let location1 = CLLocationCoordinate2D(latitude: (userLocation1?.coordinate.latitude)!, longitude: (userLocation1?.coordinate.longitude)!)
        
        self.Current_Latitude = userLocation1?.coordinate.latitude
        self.current_Longitude = userLocation1?.coordinate.longitude
        print(self.Current_Latitude)
        
        print(self.current_Longitude)
        myLocation = location1
        
        
        
        
        locationManager.stopUpdatingLocation()
        
        
        
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.sourceApplication])
        return handled
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}


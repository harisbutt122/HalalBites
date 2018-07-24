//
//  Contants.swift
//  HalalBytes
//
//  Created by harisbutt on 6/7/18.
//  Copyright © 2018 Ammar Waheed. All rights reserved.
//

import Foundation

let LoginAPI = "https://www.halalbites.org/api/login"
let RefreshTokenAPI = "https://www.halalbites.org/api/refresh-token"
let HomeDataAPI = "https://www.halalbites.org/api/home-data"
let CusinesAPI = "https://www.halalbites.org/api/cuisines"
let AddRestaurantsAPI = "https://www.halalbites.org/api/restaurant/add"
let SearchAPI = "https://www.halalbites.org/api/restaurant/search"
let HoursAPI = "https://www.halalbites.org/api/restaurant/hours/"
let QrcodeAPI = "https://www.halalbites.org/api/deal/details/"

struct HeaderParamters {
    
    let AcceptKey = "Accept"
    let ValueKey = "application/json"
    let AUthorizationKey = "Authorization"
    let AuthorizationValue = "accept"
    
}
struct BodyParameters {
    let email:String!
    let name:String!
}
class FetchData{
    
    static let shared = FetchData()
    var ReFresh_Token_singleTon = ""
    
    private init(){}
    
    

    
}
//struct LatLong{
//    var Latitude:CLLocationDegrees
//    var Longitude:CLLocationDegrees
//}


struct restaurantsDetails{
    var ImageURL:String!
    var Name:String!
    var Cusine:[JSON]!
    var halalnessLevel:String!
    var suburb:String!
    var distance:Double!
    var PhoneNumber:String!
    var Address:String!
    var latitude:Double!
    var longitude:Double!
    var rating:Double!
    var OpenClose:Bool!
    var weekday_text:[Any]!
}

struct RatingOpenNow {
    
}
struct GetSelectedCuisines_IDs{
    var Cuisines:String!
    var ID:Int!
    
    
}

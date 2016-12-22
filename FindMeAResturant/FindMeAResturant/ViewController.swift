//
//  ViewController.swift
//  FindMeAResturant
//
//  Created by Kasra Sheik on 11/12/16.
//  Copyright © 2016 Kasra Sheik. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    let locationManager =  CLLocationManager()
    var lat = 0.0
    var long = 0.0
    
    
    @IBOutlet var restaurantName: UILabel!
    
    @IBOutlet var restaurantImage: UIImageView!
   
    @IBOutlet var openLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
 
    @IBOutlet var descriptionLabel: UITextView!
    
    @IBOutlet var dashedLine: UILabel!
    
    @IBOutlet var aboutLabel: UILabel!
    
    @IBOutlet var contactLabel: UILabel!
    
    @IBOutlet var telephoneLabel: UILabel!
    
    @IBOutlet var telephoneNumber: UILabel!
    
    @IBOutlet var ratingImage: UIImageView!
    
    
    @IBOutlet var reviewCount: UILabel!
    
    @IBOutlet var mapView: MKMapView!
    
    var userPreferences:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "RestaWant"
        self.restaurantName.isHidden = true
        self.descriptionLabel.isHidden = true
        self.aboutLabel.isHidden = true
        self.categoryLabel.isHidden = true
        self.openLabel.isHidden = true
        self.telephoneNumber.isHidden = true
        self.restaurantImage.isHidden = true
        self.dashedLine.isHidden = true
        self.ratingImage.isHidden = true
        self.reviewCount.isHidden = true
        self.mapView.isHidden = true
        
        
        
        
        let defaults = UserDefaults.standard
        if(defaults.object(forKey: "userPreferences") == nil) {
            //set and store default preferences
            var userPreferences:[String] = []
            userPreferences.append("2000")
            userPreferences.append("0")
            userPreferences.append("low")
            userPreferences.append("")
            
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: userPreferences)
            defaults.set(encodedData, forKey: "userPreferences")
            defaults.synchronize()
            
            
            self.userPreferences = userPreferences
            self.mapView.delegate = self
            
            //loadInitialData()
        
          

        }
        
        
        
        
        
    
        
        // Ask for Authorisation from the User.
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func displayLocationInfo(_ placemark: CLPlacemark)
    {
        
        self.locationManager.stopUpdatingLocation()
        print(placemark.locality)
        print(placemark.postalCode)
        print(placemark.administrativeArea)
        print(placemark.country)
        
    }
    
    func locationManager(_ manager: CLLocationManager!, didFailWithError error: Error)
    {
        print("Error: " + error.localizedDescription)
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.lat = (locValue.latitude)
        self.long = locValue.longitude
        self.locationManager.stopUpdatingLocation()
        
        print("WE ARE HERE")
        }
    
    @IBAction func findRestaurant(_ sender: AnyObject) {
        
        
        //these our our user's preferences..include this in post request
        
        let defaults = UserDefaults.standard
        let decodedData = defaults.object(forKey: "userPreferences") as! NSData
        var userPreferences = NSKeyedUnarchiver.unarchiveObject(with: decodedData as Data) as! [String]
        
        print(userPreferences[3])
        
        
        let keyword = userPreferences[3]
        let distance = Float(userPreferences[0])
        let ratings = Float(userPreferences[1])
        
        print(distance)
        
        let parameters: [String: AnyObject] = [
            "keyword": userPreferences[3] as AnyObject,
            "latitude": self.lat as AnyObject,
            "longitude": self.long as AnyObject,
            "distance": distance as AnyObject,
            
        ]
        
        
        Alamofire.request("https://find-me-a-restaurant.herokuapp.com/", method: .post, parameters: parameters).responseJSON { response in
           
            print(response.result.value)
            let json = JSON(response.result.value)
            
            if(response.result.value == nil) {
                //show alert
                
                 let alert = UIAlertController(title: "No Restaurants Found", message: "Try broadening your search.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            }
            
            if let JSON = response.result.value {
                print(json["name"])
                
                
                
                self.restaurantName.text = json["name"].stringValue
                self.descriptionLabel.text = json["desc"].stringValue
                self.categoryLabel.text = json["categories"][0][0].stringValue
                if(json["categories"].count > 1) {
                    self.categoryLabel.text = json["categories"][0][0].stringValue + ", " + json["categories"][1][0].stringValue
                }
                
                
                self.telephoneNumber.text = json["phone"].stringValue
                self.reviewCount.text = json["review_count"].stringValue + " reviews"
                
                if(json["img_url"] != nil) {
                    let restaurantImage = URL(string: json["img_url"].stringValue)
                    let data = try? Data(contentsOf: restaurantImage!)
                    self.restaurantImage.image = UIImage(data: data!)
                }
                
                
                if(json["rating_img"] != nil) {
                    let ratingImage = URL(string: json["rating_img"].stringValue)
                    let data = try? Data(contentsOf: ratingImage!)
                    self.ratingImage.image = UIImage(data: data!)
                }

                let restLat = json["coordinates"][0].floatValue
                let restLong = json["coordinates"][1].floatValue
                self.populateUI(restLat: restLat, restLong: restLong)

            }
            
            
        }
    
        
    }
    
    func populateUI(restLat: Float, restLong: Float) {
        
        
        let initialLocation = CLLocation(latitude: self.lat, longitude: self.long)
        centerMapOnLocation(location: initialLocation)

        let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(restLat), CLLocationDegrees(restLong))
        
        
        let selectedRestaurant = Restaurant(name: "test!", coordinate: coordinate)
       
        mapView.addAnnotation(selectedRestaurant)
        
        restaurantName.isHidden = false
        descriptionLabel.isHidden = false
        aboutLabel.isHidden = false
        categoryLabel.isHidden = false
        restaurantImage.isHidden = false
        telephoneNumber.isHidden = false
        openLabel.isHidden = false
        dashedLine.isHidden = false
        mapView.isHidden = false
        
        ratingImage.isHidden = false
        reviewCount.isHidden = false
        
        
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        print("whats up!!!")
        if let annotation = annotation as? Restaurant {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                let btn = UIButton(type: .detailDisclosure)
                view.rightCalloutAccessoryView = btn
            }
            return view
        }
        print("hi there")
        return nil
    }
 
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let identifier = "pin"
//        
//        if annotation is Restaurant {
//            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
//                annotationView.annotation = annotation
//                return annotationView
//            } else {
//                let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:identifier)
//                annotationView.isEnabled = true
//                annotationView.canShowCallout = true
//                
//                let btn = UIButton(type: .detailDisclosure)
//                annotationView.rightCalloutAccessoryView = btn
//                return annotationView
//            }
//        }
//        
//        return nil
//    }
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
                 calloutAccessoryControlTapped control: UIControl!) {
        let location = view.annotation as! Restaurant
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        location.mapItem().openInMaps(launchOptions: launchOptions)
        
    }
    
//    func openMapForPlace() {
//        
//        let lat1 : NSString = self.venueLat
//        let lng1 : NSString = self.venueLng
//        
//        let latitude:CLLocationDegrees =  lat1.doubleValue
//        let longitude:CLLocationDegrees =  lng1.doubleValue
//        
//        let regionDistance:CLLocationDistance = 10000
//        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
//        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
//        let options = [
//            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
//            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
//        ]
//        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
//        let mapItem = MKMapItem(placemark: placemark)
//        mapItem.name = "\(self.venueName)"
//        mapItem.openInMapsWithLaunchOptions(options)
//        
//    }
    @IBAction func settingsSaved(segue:UIStoryboardSegue) {
        print("settings were saved..")
    }
    
}


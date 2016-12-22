//
//  Restaurant.swift
//  FindMeAResturant
//
//  Created by Kasra Sheik on 11/12/16.
//  Copyright © 2016 Kasra Sheik. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import MapKit


class Restaurant:NSObject, MKAnnotation {
    var name: String = ""
    let coordinate: CLLocationCoordinate2D
    
    
    
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.coordinate = coordinate
        
        super.init()
    }
    func mapItem() -> MKMapItem {
        if #available(iOS 10.0, *) {
            let placemark = MKPlacemark.init(coordinate: coordinate)
        } else {
            // Fallback on earlier versions
        }
        //
        //let mapItem = MKMapItem(placemark: placemark)
        mapItem().name = name
        
        return mapItem()
    }
    
    
}

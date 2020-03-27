//
//  LocationService.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//

import Foundation
import CoreLocation
import ReactiveSwift
import UIKit

typealias Coordinate = (latitude: Double, longitude: Double)

class LocationService: NSObject {
    
    private static let sharedInstance = LocationService()
    
    private var lastCoordinate: Coordinate?
    
    private let locationManager = CLLocationManager()
    private var callback: ((Coordinate) -> ())?
    
    private override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    static var enabled: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    static func lastLocation() -> Coordinate? {
        return sharedInstance.lastCoordinate
    }
    
    static func askPermission() {
        if !CLLocationManager.locationServicesEnabled() {
            sharedInstance.locationManager.requestWhenInUseAuthorization()
            return
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            sharedInstance.locationManager.requestWhenInUseAuthorization()
        case .denied:
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        default: ()
        }
    }
    
    static func location() -> SignalProducer<Coordinate, NSError> {
        return SignalProducer { sink, disposable in
            
            sharedInstance.callback = { coordinate in
                sink.send(value:coordinate)
                sink.sendCompleted()
                self.sharedInstance.locationManager.stopUpdatingLocation()
            }
            
            sharedInstance.locationManager.startUpdatingLocation()
            
            disposable.observeEnded {
                self.sharedInstance.locationManager.stopUpdatingLocation()
            }
        }
    }
    
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = Double(location.coordinate.latitude)
            let longitude = Double(location.coordinate.longitude)
            let coords = (latitude, longitude)
            lastCoordinate = coords
            callback?(coords)
        }
    }
    
}

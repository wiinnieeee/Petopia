//
//  NearbyPetShopsViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 29/5/2023.
//

import UIKit
import CoreLocation
import MapKit

class NearbyPetShopsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
    }
    
    func getUserLocation() {
        LocationService.shared.locationUpdated = {
            location in
            self.fetchPlaces(location: location)
        }
    }
        
    func fetchPlaces (location: CLLocationCoordinate2D) {
        let searchSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let searchRegion = MKCoordinateRegion(center: location, span: searchSpan)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.region = searchRegion
        searchRequest.resultTypes = .pointOfInterest
        searchRequest.naturalLanguageQuery = "Pet Shop"
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let mapItems = response?.mapItems else {
                return
            }
            let results = mapItems.map({($0.name ?? "No Name found")})
            print(results)
        }
    }
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
}

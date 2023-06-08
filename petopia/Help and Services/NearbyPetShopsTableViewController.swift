//
//  NearbyPetShopsTableViewController.swift
//  petopia
//  Display the nearby pet shops in a list
//  Reference: https://www.youtube.com/watch?v=YCmZayf7Zi4
//
//  Created by Winnie Ooi on 29/5/2023.
//

import UIKit
import CoreLocation
import MapKit

class NearbyPetShopsTableViewController: UITableViewController {
    var places : [Place] = []
    var locationList = [LocationAnnotation]()
    var userLoc: CLLocation?
    var newPlace: Place?
    
    // Loads user current location once the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
    }
    
    /// Obtains the user current location
    func getUserLocation() {
        LocationService.shared.locationUpdated = {
            location in
            self.fetchPlaces(location: location)
            self.userLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
        }
    }
    
    /// Fetching the nearby pet shops to the current location of the user
    func fetchPlaces (location: CLLocationCoordinate2D) {
        let searchSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let searchRegion = MKCoordinateRegion(center: location, span: searchSpan)
        
        // Conditions of the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.region = searchRegion
        searchRequest.resultTypes = .pointOfInterest
        searchRequest.naturalLanguageQuery = "Pet Shop"
        
        // Search according to the search request conditions
        let search = MKLocalSearch(request: searchRequest)
        
        // Start the search
        search.start { response, error in
            // mapItems is the array containing nearby pet shops obtained
            guard let mapItems = response?.mapItems else {
                return
            }
            DispatchQueue.main.async {
                [weak self] in
                for items in mapItems {
                    // create a new place object and append in the list of places
                    var newPlace = Place()
                    newPlace.name = items.name
                    newPlace.phoneNumber = items.phoneNumber
                    newPlace.url = items.url
                    newPlace.coordinates = items.placemark.location
                    newPlace.distanceFromUser = String(format: "%.2f", ((items.placemark.location!.distance(from: self!.userLoc!)) / 1000 )) + " kilometres"
                    newPlace.annotation = LocationAnnotation(title: items.name!, lat: items.placemark.coordinate.latitude , long: items.placemark.coordinate.longitude)
                    self?.places.append(newPlace)
                }
                // Sort the places by the distance from the user
                self?.places.sort(by: {$0.distanceFromUser! < $1.distanceFromUser!})
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    // Populate the rows in the section
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "petShopsCell", for: indexPath)
        let nearbyShops = places[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = nearbyShops.name
        content.secondaryText = nearbyShops.distanceFromUser
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Navigation
    // Pass the selected row to the next view controller to display details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewPlace" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as? ViewPetShopViewController
                let placeSelected = places[indexPath.row]
                destination?.selectedPlace = placeSelected
                destination?.userLoc = userLoc
            }
        }
    }
}

//
//  NearbyVetsTableViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 29/5/2023.
//

import UIKit
import MapKit
import CoreLocation

class NearbyVetsTableViewController: UITableViewController {
    var places : [Place] = []
    var locationList = [LocationAnnotation]()
    var userLoc: CLLocation?
    var newPlace: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
    }
    
    func getUserLocation() {
        LocationService.shared.locationUpdated = {
            location in
            self.fetchPlaces(location: location)
            self.userLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
        }
    }
    
    func fetchPlaces (location: CLLocationCoordinate2D) {
        let searchSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let searchRegion = MKCoordinateRegion(center: location, span: searchSpan)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.region = searchRegion
        searchRequest.resultTypes = .pointOfInterest
        searchRequest.naturalLanguageQuery = "Vet"
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let mapItems = response?.mapItems else {
                return
            }
            DispatchQueue.main.async {
                [weak self] in
                for items in mapItems {
                    var newPlace = Place()
                    newPlace.name = items.name
                    newPlace.phoneNumber = items.phoneNumber
                    newPlace.url = items.url
                    newPlace.coordinates = items.placemark.location
                    newPlace.distanceFromUser = String(format: "%.2f", ((items.placemark.location!.distance(from: self!.userLoc!)) / 1000 )) + " kilometres"
                    newPlace.annotation = LocationAnnotation(title: items.name!, lat: items.placemark.coordinate.latitude , long: items.placemark.coordinate.longitude)
                    self?.places.append(newPlace)
                    
                }
                self?.places.sort(by: {$0.distanceFromUser! < $1.distanceFromUser!})
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "vetsCell", for: indexPath)
        let nearbyShops = places[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = nearbyShops.name
        content.secondaryText = nearbyShops.distanceFromUser
        cell.contentConfiguration = content
        return cell
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewVets" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as? ViewVetsViewController
                let placeSelected = places[indexPath.row]
                destination?.selectedPlace = placeSelected
                destination?.userLoc = userLoc
            }
            
            
        }
    }
}

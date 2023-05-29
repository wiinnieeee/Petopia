//
//  ViewPlaceViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 29/5/2023.
//

import UIKit
import CoreLocation
import MapKit

class ViewPetShopViewController: UIViewController{
    
    var selectedPlace: Place?
    var userLoc: CLLocation?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = selectedPlace?.name!
        hpLabel.text = selectedPlace?.phoneNumber!
        distanceLabel.text = selectedPlace?.distanceFromUser
        websiteLabel.text = selectedPlace?.url?.absoluteString
        
        focusOn(annotation: (selectedPlace?.annotation)!)
        
        mapView.isZoomEnabled = true
    }

    
    func focusOn (annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
        
        mapView.addAnnotation(annotation)
        
        let userAnnotation = LocationAnnotation(title: "You are here", lat: (userLoc?.coordinate.latitude)!, long: (userLoc?.coordinate.longitude)!)
        mapView.addAnnotation(userAnnotation)
        
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

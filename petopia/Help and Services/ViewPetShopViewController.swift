//
//  ViewPetShopViewController.swift
//  petopia
//  View the details of the pet shop selected
//  Reference: https://www.youtube.com/watch?v=YCmZayf7Zi4
//  Reference: https://tiannahenrylewis.medium.com/mapkit-drawing-a-route-on-a-map-swift-uikit-1c851d754617
//
//  Created by Winnie Ooi on 29/5/2023.
//

import UIKit
import CoreLocation
import MapKit

class ViewPetShopViewController: UIViewController, MKMapViewDelegate{
    
    var selectedPlace: Place?
    var userLoc: CLLocation?
    
    // Map view and labels
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    // Initialisation of the data passed from the place selected
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = selectedPlace?.name!
        hpLabel.text = selectedPlace?.phoneNumber!
        distanceLabel.text = selectedPlace?.distanceFromUser
        websiteLabel.text = selectedPlace?.url?.absoluteString
        
        // Map properties
        focusOn(annotation: (selectedPlace?.annotation)!)
        mapView.isZoomEnabled = true
        mapView.delegate = self
        
        // Draw route from current location to the selected pet shop
        mapRoute(origin: userLoc!.coordinate, destination: (selectedPlace?.coordinates!.coordinate)!)
    }

    /// Focus on the specific region where the annotation is in the map and add annotation to it
    func focusOn (annotation: MKAnnotation) {
        // Add annotation to the selected location
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
        mapView.addAnnotation(annotation)
        
        // Add annotation to the user current location
        let userAnnotation = LocationAnnotation(title: "You are here", lat: (userLoc?.coordinate.latitude)!, long: (userLoc?.coordinate.longitude)!)
        mapView.addAnnotation(userAnnotation)
        
    }
    
    /// Render the route using a stroke from the user current location to the selected pet shop
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        let extractedExpr = UIColor.systemPink
        renderer.strokeColor = extractedExpr
        renderer.lineWidth = 5.0
        return renderer
    }
    
    /// Request for a route from the user current location to the selected pet shop
    func mapRoute (origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        // Get the directions to the pet shop from user location
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else {
                return
            }
            if let route = unwrappedResponse.routes.first {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
            }
        }
    }
}

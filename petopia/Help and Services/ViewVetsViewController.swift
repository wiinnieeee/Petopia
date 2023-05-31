//
//  ViewVetsViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 29/5/2023.
//

import UIKit
import MapKit
import CoreLocation

class ViewVetsViewController: UIViewController, MKMapViewDelegate {
    var selectedPlace: Place?
    var userLoc: CLLocation?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = selectedPlace?.name
        hpLabel.text = selectedPlace?.phoneNumber!
        distanceLabel.text = selectedPlace?.distanceFromUser
        websiteLabel.text = selectedPlace?.url?.absoluteString
        
        focusOn(annotation: (selectedPlace?.annotation)!)
        
        mapView.isZoomEnabled = true
        mapView.delegate = self
        
        mapRoute(origin: userLoc!.coordinate, destination: (selectedPlace?.coordinates!.coordinate)!)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         let renderer = MKPolylineRenderer(overlay: overlay)
         renderer.strokeColor = UIColor.systemPink
         renderer.lineWidth = 5.0
         return renderer
    }

    func focusOn (annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
        
        mapView.addAnnotation(annotation)
        
        let userAnnotation = LocationAnnotation(title: "You are here", lat: (userLoc?.coordinate.latitude)!, long: (userLoc?.coordinate.longitude)!)
        mapView.addAnnotation(userAnnotation)
        
    }
    
    func mapRoute (origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

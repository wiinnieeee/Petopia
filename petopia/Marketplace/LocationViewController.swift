//
//  LocationViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 3/5/2023.
//

import UIKit
import MapKit
import CoreLocation
import FloatingPanel

class LocationViewController: UIViewController, SearchViewControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let panel = FloatingPanelController()
    
    @IBAction func saveAction(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        view.addSubview(mapView)
        title = "Location"
        
        let searchVC = SearchViewController()
        searchVC.delegate = self
        
        panel.set(contentViewController: searchVC)
        panel.addPanel(toParent: self)
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func searchViewController(_ vc: SearchViewController, didSelectLocationWith coordinates: CLLocationCoordinate2D?) {
        
        guard let coordinates = coordinates else {
            return
        }
        
        print(coordinates)
        
        panel.move(to: .tip, animated: true)
        
        mapView.removeAnnotations(mapView.annotations)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)), animated: true)
        
    }
    
//    func focusOn(annotation: MKAnnotation){
//        mapView.selectAnnotation(annotation, animated: true)
//
//        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//
//        mapView.setRegion(zoomRegion, animated: true)
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

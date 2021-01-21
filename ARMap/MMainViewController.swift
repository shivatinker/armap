//
//  ViewController.swift
//  ARMap
//
//  Created by Andrii Zinoviev on 20.01.2021.
//

import UIKit
import CoreLocation

class MMainViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    
    private var blendVC: MVerticalBlendViewController
    private var arViewController: MARViewController
    private var mapViewController: MMapViewController
    
    private var myLocation: CLLocation?
    private var myBearing: Double?
    
    // MARK: Init
    public init(context: MContext) {
        arViewController = MARViewControllerImpl(context: context)
        mapViewController = MMapViewController(context: context)
        mapViewController.staticMode = true
        blendVC = MVerticalBlendViewController(topVC: arViewController,
                                               bottomVC: mapViewController,
                                               context: context)
        
        super.init(nibName: nil, bundle: nil)
        
        self.view.addSubview(blendVC.view)
        addChild(blendVC)
        blendVC.didMove(toParent: self)
        
        NSLayoutConstraint.activateConstraints(for: blendVC.view, in: view)
        
        locationManager.delegate = self
        mapViewController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setNavigationBarHidden(true, animated: false)
    }
    
    func updateMap() {
        if let myLocation = myLocation,
           let myBearing = myBearing
        {
            mapViewController.setLocation(coordinate: myLocation.coordinate, bearingAngle: myBearing)
        }
    }
}

// MARK: CLLocationManagerDelegate
extension MMainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = locations.first
        updateMap()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        myBearing = newHeading.trueHeading
        updateMap()
    }
}

// MARK: MMapViewDelegate
extension MMainViewController: MMapViewDelegate {
    public func mapView(_ mapView: MMapViewController, didUserSelectedLocation location: CLLocationCoordinate2D) {
        if let myLocation = myLocation {
            arViewController.targetBearingDegrees = myLocation.coordinate.degreesBearingToPoint(point: location)
        }
    }
}

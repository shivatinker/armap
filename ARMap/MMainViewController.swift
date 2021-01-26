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
    private let popMapViewController: MSelectTargetViewController
    private let zoomSlider: UISlider
    
    private var myLocation: CLLocation?
    private var myBearing: Double?
    
    // MARK: Init
    public init(context: MContext) {
        arViewController = MARViewControllerImpl(context: context)
        mapViewController = MMapViewController(context: context)
        blendVC = MVerticalBlendViewController(topVC: arViewController,
                                               bottomVC: mapViewController,
                                               context: context)
        popMapViewController = MSelectTargetViewController(context: context)
        
        zoomSlider = UISlider()
        zoomSlider.minimumValue = 10
        zoomSlider.maximumValue = 16
        
        super.init(nibName: nil, bundle: nil)
        view.addSubview(zoomSlider)
        
        popMapViewController.delegate = self
        
        self.view.addSubview(blendVC.view)
        addChild(blendVC)
        blendVC.didMove(toParent: self)
        title = "-1/12 ARMap"
        NSLayoutConstraint.activateConstraints(for: blendVC.view, in: view)
        
        locationManager.delegate = self
        mapViewController.delegate = self
        
        zoomSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            zoomSlider.leftAnchor.constraint(equalTo: view.centerXAnchor),
            zoomSlider.bottomAnchor.constraint(equalTo: blendVC.topVC.view.bottomAnchor, constant: -10),
            zoomSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            zoomSlider.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        view.bringSubviewToFront(zoomSlider)
        zoomSlider.setValue(mapViewController.currentCamera.zoom, animated: false)
        zoomSlider.addTarget(self, action: #selector(sliderUpdated), for: .valueChanged)
    }
    
    @objc func sliderUpdated() {
        mapViewController.updateZoom(zoomSlider.value)
        print(zoomSlider.value)
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
//        self.navigationController!.setNavigationBarHidden(true, animated: false)
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
    func mapViewDidUserTapped(_ mapView: MMapViewController) {
        print("tap")
        self.navigationController!.pushViewController(self.popMapViewController, animated: true)
        if let location = myLocation {
            self.popMapViewController.updateLocation(location.coordinate)
        }
    }
}

extension MMainViewController: MSelectTargetViewControllerDelegate {
    func selectTargetVC(_ viewController: MSelectTargetViewController, didSelectLocation location: CLLocationCoordinate2D) {
        if let myLocation = myLocation {
            arViewController.targetBearingDegrees = myLocation.coordinate.degreesBearingToPoint(point: location)
            mapViewController.updateTarget(location)
        }
    }
}

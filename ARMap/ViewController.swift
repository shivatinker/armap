//
//  ViewController.swift
//  ARMap
//
//  Created by Andrii Zinoviev on 20.01.2021.
//

import UIKit
import RealityKit
import CoreGraphics
import GoogleMaps

class ViewController: UIViewController {
    private lazy var arViewHeightConstraint: NSLayoutConstraint = {
        return arView.heightAnchor.constraint(equalToConstant: 0)
    }()
    
    
    private lazy var middleViewTopDistanceConstraint: NSLayoutConstraint = {
        return middleView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
    }()
    
    private var isViewDragStarted = false
    private let locationManager = CLLocationManager()
    private var initialARViewHeight: CGFloat = 0.0;
    
    private let arView: ARView = {
        let view = ARView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mapView: GMSMapView = {
        let view = GMSMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isMyLocationEnabled = true
        return view
    }()
    
    private let middleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        view.isOpaque = true
        view.isUserInteractionEnabled = true
        return view;
    }()
    
    private let middleDragGestureRecognizer: UIGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()
        gestureRecognizer.maximumNumberOfTouches = 1;
        return gestureRecognizer;
    }()
    
    // MARK: viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        middleDragGestureRecognizer.addTarget(self, action:#selector(updatePanGestureRecognizer(_:)))
        middleView.addGestureRecognizer(middleDragGestureRecognizer)
        
        self.view.addSubview(self.arView)
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.middleView)
        self.view.bringSubviewToFront(self.middleView)
        
        setARViewHeight(300)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            arView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            arView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            arView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            self.arViewHeightConstraint,
            
            mapView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            mapView.topAnchor.constraint(equalTo: arView.bottomAnchor),
            mapView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            middleView.widthAnchor.constraint(equalTo: safeArea.widthAnchor),
            middleView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            middleView.heightAnchor.constraint(equalToConstant: 50.0),
            self.middleViewTopDistanceConstraint,
        ])
    }
    
    // MARK: Private
    
    private func setARViewHeight(_ height: CGFloat) {
        middleViewTopDistanceConstraint.constant = height
        arViewHeightConstraint.constant = height
    }
    
    @objc func updatePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.initialARViewHeight = self.arView.frame.height
        case .changed:
            let newHeight: CGFloat = (self.initialARViewHeight + gestureRecognizer.translation(in: self.view).y)
                .clamped(to: 100...view.bounds.height-100)
            setARViewHeight(newHeight)
            view.layoutIfNeeded()
        case .ended:
            self.initialARViewHeight = 0
        default:
            break
        }
    }
}

// MARK: GMSMapViewDelegate

extension ViewController: GMSMapViewDelegate {
    
}

// MARK: CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let myLocation = locations.last else {
            return
        }
        
        self.mapView.animate(toLocation: myLocation.coordinate)
        self.mapView.animate(toZoom: 15.0)
        manager.stopUpdatingLocation()
    }
}

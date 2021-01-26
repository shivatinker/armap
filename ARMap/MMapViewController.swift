//
//  MMapViewController.swift
//  ARMap
//
//  Created by Andrii Zinoviev on 21.01.2021.
//

import Foundation
import GoogleMaps
import UIKit

public protocol MMapViewDelegate: AnyObject {
    func mapViewDidUserTapped(_ mapView: MMapViewController)
}

public class MMapViewController: UIViewController {
    
    // MARK: Private vars
    private let context: MContext
    private var mapView: GMSMapView
    public let targetMarker = GMSMarker()
    
    private let tapGR = UITapGestureRecognizer()
    
    public func updateTarget(_ location: CLLocationCoordinate2D) {
        targetMarker.map = mapView
        targetMarker.position = location
    }
    
    public func updateZoom(_ zoom: Float) {
        mapView.moveCamera(GMSCameraUpdate.zoom(to: zoom))
    }
    
    public var currentCamera: GMSCameraPosition {
        mapView.camera
    }
    
    // MARK: Init
    public init(context: MContext) {
        self.context = context
        mapView = GMSMapView(frame: .zero,
                             mapID: GMSMapID(identifier: context.configuration.googleMapsMapID),
                             camera: context.configuration.googleMapsDefaultCamera)
        
        super.init(nibName: nil, bundle: nil)
        view.addSubview(mapView)
        NSLayoutConstraint.activateConstraints(for: mapView, in: view)
        
        mapView.isMyLocationEnabled = true
//        mapView.settings.compassButton = true
        mapView.settings.consumesGesturesInView = false
        
        mapView.settings.rotateGestures = false
        mapView.settings.scrollGestures = false
        mapView.settings.tiltGestures = false
        mapView.settings.zoomGestures = false
        
        self.targetMarker.icon = context.configuration.googleMapsMarkerImage
        
        tapGR.addTarget(self, action: #selector(tap))
        self.view.addGestureRecognizer(tapGR)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tap() {
        self.delegate?.mapViewDidUserTapped(self)
    }
    
    // MARK: Public
    
    public weak var delegate: MMapViewDelegate?
    
    public var bearingAngleDegrees: Double {
        mapView.camera.bearing
    }
    
    public func setLocation(coordinate: CLLocationCoordinate2D, bearingAngle: Double, animated: Bool = false) {
        let camera = GMSCameraPosition(target: coordinate,
                                       zoom: currentCamera.zoom,
                                       bearing: bearingAngle,
                                       viewingAngle: 0)
        if animated {
            mapView.animate(to: camera)
        }
        else {
            mapView.camera = camera
        }
    }
}


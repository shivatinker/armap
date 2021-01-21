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
    func mapView(_ mapView: MMapViewController, didUserSelectedLocation location: CLLocationCoordinate2D)
}

public class MMapViewController: UIViewController {
    
    // MARK: Private vars
    private let context: MContext
    private var mapView: GMSMapView
    private let targetMarker = GMSMarker()
    
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
        mapView.settings.compassButton = true
        mapView.delegate = self
        self.targetMarker.icon = context.configuration.googleMapsMarkerImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public
    
    public weak var delegate: MMapViewDelegate?
    public var staticMode: Bool = false {
        didSet {
            mapView.settings.rotateGestures = !staticMode
            mapView.settings.scrollGestures = !staticMode
            mapView.settings.tiltGestures = !staticMode
            mapView.settings.zoomGestures = !staticMode
        }
    }
    
    public var bearingAngleDegrees: Double {
        mapView.camera.bearing
    }
    
    public func setLocation(coordinate: CLLocationCoordinate2D, bearingAngle: Double, animated: Bool = false) {
        let camera = GMSCameraPosition(target: coordinate,
                                   zoom: context.configuration.googleMapsDefaultCamera.zoom,
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

extension MMapViewController: GMSMapViewDelegate {
    public func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        targetMarker.map = mapView
        targetMarker.position = coordinate
        targetMarker.isTappable = false
        delegate?.mapView(self, didUserSelectedLocation: coordinate)
    }
}


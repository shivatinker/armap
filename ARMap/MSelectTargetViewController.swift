//
//  MSelectTargetViewController.swift
//  ARMap
//
//  Created by Andrii Zinoviev on 26.01.2021.
//

import Foundation
import UIKit
import GoogleMaps

public protocol MSelectTargetViewControllerDelegate: AnyObject {
    func selectTargetVC(_ viewController: MSelectTargetViewController, didSelectLocation: CLLocationCoordinate2D)
}

public class MSelectTargetViewController: UIViewController {
    private let context: MContext
    private let mapView: GMSMapView
    public let targetMarker = GMSMarker()
    public weak var delegate: MSelectTargetViewControllerDelegate?
    
    public init(context: MContext) {
        self.context = context
        mapView = GMSMapView(frame: .zero,
                             mapID: GMSMapID(identifier: context.configuration.googleMapsMapID),
                             camera: context.configuration.googleMapsDefaultCamera)
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        super.init(nibName: nil, bundle: nil)
        mapView.delegate = self
        view.addSubview(mapView)
        NSLayoutConstraint.activateConstraints(for: mapView, in: view)
        title = "Select target"
    }
    
    public func updateLocation(_ location: CLLocationCoordinate2D) {
        self.mapView.moveCamera(GMSCameraUpdate.setTarget(location))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MSelectTargetViewController: GMSMapViewDelegate {
    public func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        targetMarker.map = mapView
        targetMarker.position = coordinate
        delegate?.selectTargetVC(self, didSelectLocation: coordinate)
    }
}

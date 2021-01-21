//
//  ViewController.swift
//  ARMap
//
//  Created by Andrii Zinoviev on 20.01.2021.
//

import UIKit
import ARKit
import RealityKit
import SceneKit
import CoreGraphics
import GoogleMaps

struct DirectionPointer {
    var position: SCNVector3
    var node: SCNNode
}

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
    private var targetMarker: GMSMarker?
    private var myLocation: CLLocationCoordinate2D?
    private var targetDirectionPointer = DirectionPointer(position: SCNVector3(0, 0, 0),
                                                          node: SCNNode(geometry: createPointerGeometry(withColor: .purple)))
    
    private let compassPointers = [
        DirectionPointer(position: SCNVector3(0, 0, -1), node: SCNNode(geometry: createPointerGeometry(withColor: .red))),
        DirectionPointer(position: SCNVector3(0, 0, 1), node: SCNNode(geometry: createPointerGeometry(withColor: .blue))),
        DirectionPointer(position: SCNVector3(-1, 0, 0), node: SCNNode(geometry: createPointerGeometry(withColor: .green))),
        DirectionPointer(position: SCNVector3(1, 0, 0), node: SCNNode(geometry: createPointerGeometry(withColor: .green))),
    ]
    
    static func createPointerGeometry(withColor color: UIColor) -> SCNGeometry {
        let geometry = SCNSphere(radius: 0.05)
        let material = SCNMaterial()
        material.diffuse.contents = color
        geometry.firstMaterial = material
        return geometry
    }
    
    private let coachingView: ARCoachingOverlayView = {
        let view = ARCoachingOverlayView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    private let arView: ARSCNView = {
        let view = ARSCNView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mapView: GMSMapView = {
        let camera = GMSCameraPosition(latitude: 35, longitude: 35, zoom: 12)
        let view = GMSMapView(frame: .zero, mapID: GMSMapID(identifier: "b501539485a633d2"), camera: camera)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isMyLocationEnabled = true
        view.backgroundColor = .black
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
        
        middleDragGestureRecognizer.addTarget(self, action:#selector(updatePanGestureRecognizer(_:)))
        middleView.addGestureRecognizer(middleDragGestureRecognizer)
        
        self.view.addSubview(self.arView)
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.middleView)
        self.view.bringSubviewToFront(self.middleView)
        
        arView.delegate = self
        
        arView.addSubview(coachingView)
        coachingView.goal = .tracking
        coachingView.session = arView.session
        coachingView.activatesAutomatically = true
        coachingView.delegate = self
        
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
        
        for pointer in compassPointers {
            arView.scene.rootNode.addChildNode(pointer.node)
        }
        arView.scene.rootNode.addChildNode(targetDirectionPointer.node)
        targetDirectionPointer.node.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        arView.session.run(configuration, options: [.resetTracking])
        
        setARViewHeight(view.bounds.height * 0.75)
        
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
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
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let newMarker = GMSMarker(position: coordinate)
        newMarker.icon = GMSMarker.markerImage(with: .blue)
        newMarker.map = mapView
        
        targetMarker?.map = nil
        targetMarker = newMarker
    }
}

// MARK: CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let myLocation = locations.last else {
            return
        }
        
        self.myLocation = myLocation.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard let myLocation = myLocation else {
            return
        }
        
        let camera = GMSCameraPosition(target: myLocation,
                                       zoom: mapView.camera.zoom,
                                       bearing: newHeading.trueHeading,
                                       viewingAngle: mapView.camera.viewingAngle)
        self.mapView.camera = camera
    }
}

// MARK: ARCoachingOverlayView

extension ViewController: ARCoachingOverlayViewDelegate {
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let cameraPosition = arView.pointOfView!.position;
        for pointer in compassPointers {
            pointer.node.position = cameraPosition + pointer.position
        }
        if let marker = targetMarker,
           let myLocation = myLocation
        {
            self.targetDirectionPointer.node.isHidden = false
            let location = marker.position
            let bearingRadians = myLocation.bearingToPoint(point: location)
            targetDirectionPointer.node.position = 0.9 * (cameraPosition + SCNVector3(sin(bearingRadians), 0, -cos(bearingRadians)))
        }
        else {
            self.targetDirectionPointer.node.isHidden = true
        }
    }
}

extension SCNVector3 {
    static func +(vec1: SCNVector3, vec2: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(vec1.x + vec2.x,
                              vec1.y + vec2.y,
                              vec1.z + vec2.z)
    }
    
    static func *(val: Float, vec: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(val * vec.x,
                              val * vec.y,
                              val * vec.z)
    }
}

extension CLLocationCoordinate2D {
    func bearingToPoint(point: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
        func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
        
        let lat1 = degreesToRadians(degrees: self.latitude)
        let lon1 = degreesToRadians(degrees: self.longitude)

        let lat2 = degreesToRadians(degrees: point.latitude)
        let lon2 = degreesToRadians(degrees: point.longitude)

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return radiansBearing
    }
}

//
//  MContext.swift
//  ARMap
//
//  Created by Andrii Zinoviev on 21.01.2021.
//

import Foundation
import GoogleMaps

public class MContext {
    public let configuration: MConfiguration
    
    public init(configuration: MConfiguration) {
        self.configuration = configuration
    }
}

public struct MConfiguration {
    private let configDictionary: NSDictionary
    
    public let arViewCompassHeightAngleDegrees: Double = 15
    
    public let blendViewTopViewDefaultHeight: CGFloat = 450
    public let blendViewDragViewHeight: CGFloat = 50
    public let blendViewMinTopViewHeight: CGFloat = 200
    public let blendViewMinBottomViewHeight: CGFloat = 100
    
    public let googleMapsMapID = "b501539485a633d2"
    public let googleMapsDefaultCamera: GMSCameraPosition = GMSCameraPosition(latitude: 30, longitude: 30, zoom: 12)
    public let googleMapsMarkerImage: UIImage = GMSMarker.markerImage(with: .blue)
    public let googleApiKey: String
    
    public init() {
        configDictionary = NSDictionary(contentsOfFile:  Bundle.main.path(forResource: "config", ofType: "plist")!)!
        googleApiKey = configDictionary["google_api_key"] as! String
    }
}

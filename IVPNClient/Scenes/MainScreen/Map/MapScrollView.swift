//
//  MapScrollView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 20/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo

class MapScrollView: UIScrollView {
    
    // MARK: - Properties -
    
    var viewModel: ProofsViewModel! {
        didSet {
            let halfWidth = Double(size.width / 2)
            let halfHeight = Double(size.height / 2)
            let point = getCoordinatesBy(latitude: viewModel.model.latitude, longitude: viewModel.model.longitude)
            let bottomOffset = Double((MapConstants.Container.getBottomAnchor() / 2) - MapConstants.Container.topAnchor)
            setContentOffset(CGPoint(x: point.0 - halfWidth, y: point.1 - halfHeight + bottomOffset), animated: true)
        }
    }
    
    private lazy var iPadConstraints = bb.left(MapConstants.Container.iPadLandscapeLeftAnchor).top(MapConstants.Container.iPadLandscapeTopAnchor).constraints.deactivate()
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupConstraints()
    }
    
    // MARK: - Methods -
    
    func setupConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isLandscape {
            iPadConstraints.activate()
        } else {
            iPadConstraints.deactivate()
        }
    }
    
    private func placeServerLocationMarkers() {
        for server in Application.shared.serverList.servers {
            placeMarker(latitude: server.latitude, longitude: server.longitude)
        }
    }
    
    private func placeMarker(latitude: Double, longitude: Double) {
        let point = getCoordinatesBy(latitude: latitude, longitude: longitude)
        
        let marker = UIView(frame: CGRect(x: point.0 - 3, y: point.1 - 3, width: 6, height: 6))
        marker.layer.cornerRadius = 3
        marker.clipsToBounds = true
        marker.backgroundColor = .green
        
        addSubview(marker)
    }
    
    private func getCoordinatesBy(latitude: Double, longitude: Double) -> (Double, Double) {
        let bitmapWidth: Double = 3909
        let bitmapHeight: Double = 2942
        
        var y: Double
        var blackMagicCoef: Double
        
        // Using this coefficients to compensate for the curvature of the map
        let xMapCoefficient = 0.026
        let yMapCoefficient = 0.965
        
        // Logic to convert longitude, latitude into x, y
        var x: Double = (longitude + 180.0) * (bitmapWidth / 360.0)
        let latRadius: Double = latitude * Double.pi / 180
        blackMagicCoef = log(tan((Double.pi / 4) + (latRadius / 2)))
        y = (bitmapHeight / 2) - (bitmapWidth * blackMagicCoef / (2 * Double.pi))
        
        // Trying to compensate for the curvature of the map
        x -= bitmapWidth * xMapCoefficient
        if y < bitmapHeight / 2 {
            y *= yMapCoefficient
        }
        
        return (x, y)
    }
    
}

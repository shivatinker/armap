//
//  MVerticalBlendView.swift
//  ARMap
//
//  Created by Andrii Zinoviev on 21.01.2021.
//

import Foundation
import UIKit

class MVerticalBlendViewController: UIViewController {
    private let context: MContext
    
    public let topVC: UIViewController
    public let bottomVC: UIViewController
    
    private var initialTopViewHeight: CGFloat = 0.0
    private let dragView = UIView()
    
    private let dragViewGestureRecognizer: UIGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()
        gestureRecognizer.maximumNumberOfTouches = 1;
        return gestureRecognizer;
    }()
    
    private let topViewHeightConstraint: NSLayoutConstraint
    
    public init(topVC: UIViewController, bottomVC: UIViewController, context: MContext) {
        self.context = context
        self.topVC = topVC
        self.bottomVC = bottomVC
        
        let topViewHeight = context.configuration.blendViewTopViewDefaultHeight
        topViewHeightConstraint = topVC.view.heightAnchor.constraint(equalToConstant: topViewHeight)
        
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(topVC.view)
        view.addSubview(dragView)
        view.addSubview(bottomVC.view)
        
        addChild(topVC)
        topVC.didMove(toParent: self)
        addChild(bottomVC)
        topVC.didMove(toParent: self)
        
        topVC.view.translatesAutoresizingMaskIntoConstraints = false
        dragView.translatesAutoresizingMaskIntoConstraints = false
        bottomVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        dragView.addGestureRecognizer(dragViewGestureRecognizer)
        dragViewGestureRecognizer.addTarget(self, action: #selector(updatePanGestureRecognizer(_:)))
        view.bringSubviewToFront(dragView)
        
        NSLayoutConstraint.activate([
            topVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topVC.view.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            topVC.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            topViewHeightConstraint,
            
            dragView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            dragView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            dragView.heightAnchor.constraint(equalToConstant: context.configuration.blendViewDragViewHeight),
            dragView.centerYAnchor.constraint(equalTo: topVC.view.bottomAnchor),
            
            bottomVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomVC.view.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            bottomVC.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            bottomVC.view.topAnchor.constraint(equalTo: topVC.view.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func updatePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.initialTopViewHeight = topVC.view.bounds.height
        case .changed:
            let newHeight: CGFloat = (self.initialTopViewHeight + gestureRecognizer.translation(in: self.view).y)
            let minHeight = context.configuration.blendViewMinTopViewHeight
            let maxHeight = view.bounds.height-context.configuration.blendViewMinBottomViewHeight
            topViewHeightConstraint.constant = newHeight.clamped(to: minHeight...maxHeight)
            view.layoutIfNeeded()
        case .ended:
            self.initialTopViewHeight = 0
        default:
            break
        }
    }
}

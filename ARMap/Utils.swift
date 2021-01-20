//
//  Utils.swift
//  ARMap
//
//  Created by Andrii Zinoviev on 20.01.2021.
//

import Foundation

public extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
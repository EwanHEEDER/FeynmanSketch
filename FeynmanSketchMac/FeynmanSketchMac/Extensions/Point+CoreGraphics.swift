//
//  Point+CoreGraphics.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 08/08/2026.
//

import CoreGraphics
import DiagramModel

/// Allows to easily convert ``Point`` to ``CGPoint`` and vice versa
extension Point {
    init(_ cgPoint: CGPoint) {
        self.init(x: cgPoint.x, y: cgPoint.y)
    }
    
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

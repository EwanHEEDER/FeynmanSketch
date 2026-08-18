//
//  ArcGeometry.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 18/08/2026.
//

import SwiftUI

enum ArcGeometry {
    static func midpointOfArc(from start: CGPoint, to end: CGPoint, curvatureDegrees: Double) -> CGPoint {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = sqrt(dx * dx + dy * dy)
        let angle = atan2(dy, dx)
        
        let midX = (start.x + end.x) / 2
        let midY = (start.y + end.y) / 2
        
        guard curvatureDegrees != 0, length > 0 else {
            return CGPoint(x: midX, y: midY)
        }
        
        let theta = curvatureDegrees * .pi / 180
        let sagitta = (length / 2) * tan(theta / 2)
        
        // Mid-curve point is perpendicular to middle of straight segment, wrt sagita distance and direction
        let perpendicularX = -sin(angle) * sagitta
        let perpendicularY = cos(angle) * sagitta
        
        return CGPoint(x: midX + perpendicularX, y: midY + perpendicularY)
    }
    
    static func  projectedOffset(mouseLocation: CGPoint, start: CGPoint, end: CGPoint) -> Double {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = sqrt(dx * dx + dy * dy)
        guard length > 0 else { return 0 }
        
        let angle = atan2(dy, dx)
        let midX = (start.x + end.x) / 2
        let midY = (start.y + end.y) / 2
        
        let vx = mouseLocation.x - midX
        let vy = mouseLocation.y - midY
        
        let perpendicularX = -sin(angle)
        let perpendicularY = cos(angle)
        
        let offset = (vx * perpendicularX + vy * perpendicularY)
        
        return Double(offset)
    }
    
    static func curvatureDegrees(forSagitta h: Double, length: Double) -> Double {
        guard length > 0 else { return 0 }
        let theta = 2 * atan2(2 * h, length)
        return theta * 180 / .pi
    }
    
    static func snappedCurvature(_ degrees: Double, threshold: Double = 5) -> Double { // Parse snapTargets and if given curvature is close enough to a target, returns it. Else, returns original curvature
        let snapTargets: [Double] = [-90, -45, 0, 45, 90]
        for target in snapTargets {
            if abs(degrees - target) <= threshold {
                return target
            }
        }
        return degrees
    }
}

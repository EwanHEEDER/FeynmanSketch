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
    
    static func arcPoint(from start: CGPoint, to end: CGPoint, curvatureDegrees: Double, t: CGFloat) -> (point: CGPoint, tangentAngle: CGFloat) {
        let dx = Double(end.x - start.x)
        let dy = Double(end.y - start.y)
        let length = sqrt(dx * dx + dy * dy)
        let chordAngle = atan2(dy, dx)
        
        guard curvatureDegrees != 0, length > 0 else {
            let x = Double(start.x) + Double(t) * dx
            let y = Double(start.y) + Double(t) * dy
            return (CGPoint(x: x, y: y), chordAngle)
        }
        
        let theta = curvatureDegrees * .pi / 180
        let radius = length / (2 * sin(theta))
        let unsignedRadius = abs(radius)
        
        let perpX = -sin(chordAngle)
        let perpY = cos(chordAngle)
        
        let midX = (Double(start.x) + Double(end.x)) / 2
        let midy = (Double(start.y) + Double(end.y)) / 2
        
        let centerOffset = -radius * cos(theta)
        let centerX = midX + centerOffset * perpX
        let centerY = midy + centerOffset * perpY
        
        let angleToStart = atan2(Double(start.y) - centerY, Double(start.x) - centerX)
        let angleAtT = angleToStart - Double(t) * 2 * theta
        
        let pointX = centerX + unsignedRadius * cos(angleAtT)
        let pointY = centerY + unsignedRadius * sin(angleAtT)
        
        let tangentAngle = angleAtT - (theta >= 0 ? .pi / 2 : -.pi / 2)
        
        return (CGPoint(x: pointX, y: pointY), CGFloat(tangentAngle))
    }
    
    static func arcLength(from start: CGPoint, to end: CGPoint, curvatureDegrees: Double) -> Double {
        let dx = Double(end.x - start.x)
        let dy = Double(end.y - start.y)
        let length = sqrt(dx * dx + dy * dy)
        
        guard curvatureDegrees != 0, length > 0 else { return length }
        
        let theta = curvatureDegrees * .pi / 180
        let radius = length / (2 * sin(theta))
        
        return abs( radius * 2 * theta )
    }
}

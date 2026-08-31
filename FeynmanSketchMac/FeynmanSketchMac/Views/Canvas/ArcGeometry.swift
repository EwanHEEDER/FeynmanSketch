//
//  ArcGeometry.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 18/08/2026.
//

import SwiftUI

/// Geometry helpers for representing a curved  ``PropagatorLine`` as  a proper circular arc.
///
/// A line's curvature is stored as an angle in degrees, following Typst fletcher's convention: it corresponds to the angle between the chord and the tangent vector to the arc at its starting point. This type converts between that angle and the actual circle (center, radius, point positions) needed to draw or interact with the curve.
enum ArcGeometry {
    /// The midpoint of the arc between two points, given its curvature.
    ///
    /// For zero curvature, this is simply the geometric midpoint of the segment. Otherwise, it is offset perpendicular to the chord by the arc's sagitta.
    ///  - Parameters:
    ///         - start: the arc's starting point.
    ///         - end: the arc's ending point.
    ///         - curvatureDegrees: the bend angle, in degrees. `0` produces a straight line.
    ///   - Returns: the midpoint of the curve.
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
    
    /// Projects a point (typically a mouse or drag location) onto the axis perpendicular to a segment, passing through its midpoint
    ///
    /// For an arbitrary 2D point, returns the sagitta. Applied each time the curvature control point is dragged by the user for real-time curvature adjustement.
    /// Any component of the point's position parallel to the chord is ignored, so the dragged point is visually constrained to the chord's perpendicular bisector.
    ///  - Parameters:
    ///         - mouseLocation: the point to project (e.g the current drag location).
    ///         - start: the starting point of the segment.
    ///         - end: the ending point of the segment.
    ///  - Returns: the signed distance between the given point and the chord along the perpendicular axis. The sign indicates which side of the chord the point falls on.
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
    
    /// Converts a  sagitta into a bend angle.
    ///
    ///  - Parameters:
    ///         - h: the sagitta, typically obtained from ``projectedOffset(mouseLocation:start:end:)``.
    ///         - length: the chord's length.
    ///  - Returns: The bend angle of the arc, in degrees.
    static func curvatureDegrees(forSagitta h: Double, length: Double) -> Double {
        guard length > 0 else { return 0 }
        let theta = 2 * atan2(2 * h, length)
        return theta * 180 / .pi
    }
    
    /// Snaps a curvature angle to the closest value in a list of chosen angles (`snapTargets`) if it falls within a threshold, else, just returns the initial value.
    ///
    /// It helps the user building symmetric diagrams without pixel-order precision.
    /// - Parameters:
    ///         - degrees: bend angle to eventually snap, in degrees
    ///         - threshold: the acceptance below which an angle is snapped to the closest target, in degrees. Defaults to 5.
    ///  - Returns: the snapped value, if snapped. Else, the unchanged `degrees`.
    static func snappedCurvature(_ degrees: Double, threshold: Double = 5) -> Double { // Parse snapTargets and if given curvature is close enough to a target, returns it. Else, returns original curvature
        let snapTargets: [Double] = [-90, -45, 0, 45, 90]
        for target in snapTargets {
            if abs(degrees - target) <= threshold {
                return target
            }
        }
        return degrees
    }
    
    /// A point on the arc at a given fraction of its length, along with the angle between x axis and the direction of the tangent to the curve at that point.
    ///
    /// For zero curvature, returns an interpolation of segment's midpoint and the direction of the chord itself (angle between the chord and the x-axis).
    /// Otherwise, point is computed by rotating around the arc's circle center, and the tangent is perpendicular to the radius at that point. This makes the drawing of line styles follow the curve rather than the straight chord.
    /// - Parameters:
    ///         - start: starting point of the arc.
    ///         - end: ending point of the arc.
    ///         - curvatureDegrees: bend angle of the arc, in degrees.
    ///         - t: fraction of the arc's length, from `0` to `1`, resp. `start` to `end`.
    /// - Returns: the point on the arc at fraction `t` of total length, and angle between tangent direction to the curve at that point and x-axis of the canvas, **in radians**.
    static func arcPoint(from start: CGPoint, to end: CGPoint, curvatureDegrees: Double, t: CGFloat) -> (point: CGPoint, tangentAngle: CGFloat) {
        let dx = Double(end.x - start.x)
        let dy = Double(end.y - start.y)
        let length = sqrt(dx * dx + dy * dy)
        let chordAngle = atan2(dy, dx)
        
        guard curvatureDegrees != 0, length > 0 else {
            let x = Double(start.x) + Double(t) * dx
            let y = Double(start.y) + Double(t) * dy
            return (CGPoint(x: x, y: y), CGFloat(chordAngle))
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
    
    /// The total length of an arc between two points, with given curvature.
    ///
    /// For zero curvature, it is simply the straight-line distance between `start` and `end`.
    /// Otherwise, it's the arc length of the corresponding circular arc. Used by line styles to to advance decorations based on the true distance advanced along the arc, rather than along the chord.
    ///  - Parameters:
    ///         - start: starting point of the arc.
    ///         - end: ending point of the curve.
    ///         - curvatureDegrees: bend angle of the arc, in degrees.
    /// - Returns: the total arc length, always zero or positive.
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

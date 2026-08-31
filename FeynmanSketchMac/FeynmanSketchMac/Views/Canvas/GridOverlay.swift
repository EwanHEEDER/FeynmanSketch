//
//  GridOverlay.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 12/08/2026.
//

import SwiftUI

/// Draw a background grid on the canvas, matching the spacing used for vertex snapping.
enum GridOverlay {
    
    /// Draws vertical and horizontal grid lines spaced evenly across the given area.
    ///  - Parameters:
    ///         - context: the graphic context to draw the grid into.
    ///         - size: the size of the area to fill with the grid.
    ///         - spacing: the distance between two consecutive grid lines, in screen points.
    static func draw(in context: GraphicsContext, size: CGSize, spacing: CGFloat) {
        var path = Path()
        
        // plot along x
        var x: CGFloat = 0
        while x < size.width {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            x += spacing
        }
        
        // plot along y
        
        var y: CGFloat = 0
        while y < size.height {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            y += spacing
        }
        
        context.stroke(path, with: .color(.gray.opacity(0.40)), lineWidth: 0.75)
    }
}

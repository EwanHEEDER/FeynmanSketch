//
//  CanvasStyle.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 18/08/2026.
//

import CoreGraphics

/// Shared visual constants for drawing the diagram on the canvas.
enum CanvasStyle {
    /// Stroke width used for every line style.
    static let lineWidth: CGFloat = 1
    /// Diameter of a vertex, as drawn on the canvas.
    static let vertexDiameter: CGFloat = 10
    /// Diameter of a line's draggable point for curvature adjustment.
    static let curvaturehandleDiameter: CGFloat = 10
}

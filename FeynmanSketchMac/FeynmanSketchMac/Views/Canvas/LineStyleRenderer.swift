//
//  LineStyleRenderer.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 17/08/2026.
//

import SwiftUI
import DiagramModel

enum LineStyleRenderer {
    static func draw(_ type : LineType, from start: CGPoint, to end: CGPoint, curvatureDegrees: Double, color: Color, in context: GraphicsContext) {
        switch type {
        case .scalar:
            drawScalarLine(from: start, to: end, curvatureDegrees: curvatureDegrees, color: color, in: context)
        case .fermion:
            drawFermionLine(from: start, to: end, curvatureDegrees: curvatureDegrees, color: color, in: context)
        case .vector:
            drawVectorLine(from: start, to: end, curvatureDegrees: curvatureDegrees, color: color, in: context)
        case .gluon:
            drawGluonLine(from: start, to: end, curvatureDegrees: curvatureDegrees, color: color, in: context)
        }
    }
    
    private static func drawScalarLine(from startingPoint: CGPoint, to endPoint: CGPoint, curvatureDegrees: Double, color: Color, in context: GraphicsContext) {
        var path = Path()
        let steps = 40
        
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let (point, _) = ArcGeometry.arcPoint(from: startingPoint, to: endPoint, curvatureDegrees: curvatureDegrees, t: t)
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        let style = StrokeStyle(lineWidth: CanvasStyle.lineWidth, dash: [6,4])
        context.stroke(path, with: .color(color), style: style)
    }
    
    private static func drawFermionLine(from startingPoint: CGPoint, to endPoint: CGPoint, curvatureDegrees: Double, color: Color, in context: GraphicsContext) {
        var path = Path()
        let steps = 40
        
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let (point, _) = ArcGeometry.arcPoint(from: startingPoint, to: endPoint, curvatureDegrees: curvatureDegrees, t: t)
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        context.stroke(path, with: .color(color), lineWidth: CanvasStyle.lineWidth)
        
        // Draw the small arrow indicating particle/antiparticle
        
        let (midPoint, tangentAngle) = ArcGeometry.arcPoint(from: startingPoint, to: endPoint, curvatureDegrees: curvatureDegrees, t: 0.5)
        let arrowLength: CGFloat = 8
        let arrowAngle: CGFloat = .pi / 6
        
        let leftPoint = CGPoint(
            x: midPoint.x - arrowLength * cos(tangentAngle - arrowAngle),
            y: midPoint.y - arrowLength * sin(tangentAngle - arrowAngle)
        )
        
        let rightPoint = CGPoint(
            x: midPoint.x - arrowLength * cos(tangentAngle + arrowAngle),
            y: midPoint.y - arrowLength * sin(tangentAngle + arrowAngle)
        )
        
        var arrowPath = Path()
        arrowPath.move(to: leftPoint)
        arrowPath.addLine(to: midPoint)
        arrowPath.addLine(to: rightPoint)
        
        context.stroke(arrowPath, with: .color(color), lineWidth: CanvasStyle.lineWidth)
    }
    
    private static func drawVectorLine(from startingPoint: CGPoint, to endPoint: CGPoint, curvatureDegrees: Double, color: Color, in context: GraphicsContext) { // Creating successive points following sinus func and add them to line path
        
        let totalLength = ArcGeometry.arcLength(from: startingPoint, to: endPoint, curvatureDegrees: curvatureDegrees)
        let amplitude: CGFloat = 4
        let wavelength: CGFloat = 12
        let steps = max(Int(totalLength / 2), 1)
        
        var path = Path()
        
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let (basepoint, tangentAngle) = ArcGeometry.arcPoint(from: startingPoint, to: endPoint, curvatureDegrees: curvatureDegrees, t: t)
            
            let distanceAlong = t * CGFloat(totalLength)
            let perpendicularOffset = amplitude * sin(2 * .pi * distanceAlong / wavelength)
            
            let offsetX = basepoint.x - perpendicularOffset * sin(tangentAngle)
            let offsetY = basepoint.y + perpendicularOffset * cos(tangentAngle)
            
            let point = CGPoint(x: offsetX, y: offsetY)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        context.stroke(path, with: .color(color), lineWidth: CanvasStyle.lineWidth)
        
    }
    
    private static func drawGluonLine(from startingPoint: CGPoint, to endPoint: CGPoint, curvatureDegrees: Double, color: Color, in context: GraphicsContext) {
        
        let totalLength = ArcGeometry.arcLength(from: startingPoint, to: endPoint, curvatureDegrees: curvatureDegrees)
        let radius: CGFloat = 7
        let loopsCount: CGFloat = max(totalLength / 15, 1)
        let advancePerRadian = totalLength / (loopsCount * .pi * 2)
        let steps = max(Int(loopsCount * 40), 1)
        
        var path = Path()
        
        for i in 0...steps {
            let tRaw = CGFloat(i)  / CGFloat(steps) * loopsCount * 2 * .pi
            
            // Local position in trochoidal frame
            let localX = advancePerRadian * tRaw + radius * cos(tRaw)
            let localY = radius * sin(tRaw)
            
            // line abscissa of this point
            let tNormalized = min(max(localX / CGFloat(totalLength), 0), 1)
            let (basePoint, tangentAngle) = ArcGeometry.arcPoint(from: startingPoint, to: endPoint, curvatureDegrees: curvatureDegrees, t: tNormalized)
            
            // Project from local frame to canvas frame
            let worldX  = basePoint.x - localY * sin(tangentAngle)
            let worldY  = basePoint.y + localY * cos(tangentAngle)
            
            let point = CGPoint(x: worldX, y: worldY)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        context.stroke(path, with: .color(color), lineWidth: CanvasStyle.lineWidth)
    }
}

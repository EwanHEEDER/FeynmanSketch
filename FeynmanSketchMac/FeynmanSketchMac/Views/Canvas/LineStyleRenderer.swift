//
//  LineStyleRenderer.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 17/08/2026.
//

import SwiftUI
import DiagramModel

enum LineStyleRenderer {
    static func draw(_ type : LineType, from start: CGPoint, to end: CGPoint, color: Color, in context: GraphicsContext) {
        switch type {
        case .scalar:
            drawScalarLine(from: start, to: end, color: color, in: context)
        case .fermion:
            drawFermionLine(from: start, to: end, color: color, in: context)
        case .vector:
            drawVectorLine(from: start, to: end, color: color, in: context)
        case .gluon:
            drawGluonLine(from: start, to: end, color: color, in: context)
        }
    }
    
    private static func drawScalarLine(from startingPoint: CGPoint, to endPoint: CGPoint, color: Color, in context: GraphicsContext) {
        var path = Path()
        path.move(to: startingPoint)
        path.addLine(to: endPoint)
        
        let style = StrokeStyle(lineWidth: 1.5, dash: [6,4])
        context.stroke(path, with: .color(color), style: style)
    }
    
    private static func drawFermionLine(from startingPoint: CGPoint, to endPoint: CGPoint, color: Color, in context: GraphicsContext) {
        var path = Path()
        path.move(to: startingPoint)
        path.addLine(to: endPoint)
        
        context.stroke(path, with: .color(color), lineWidth: 1.5)
        
        // Draw the small arrow indicating particle/antiparticle
        
        let midPoint = CGPoint(x: (startingPoint.x + endPoint.x) / 2, y: (startingPoint.y + endPoint.y) / 2)
        let angle = atan2(endPoint.y - startingPoint.y, endPoint.x - startingPoint.x)
        let arrowLength: CGFloat = 8
        let arrowAngle: CGFloat = .pi / 6
        
        let leftPoint = CGPoint(
            x: midPoint.x - arrowLength * cos(angle - arrowAngle),
            y: midPoint.y - arrowLength * sin(angle - arrowAngle)
        )
        
        let rightPoint = CGPoint(
            x: midPoint.x - arrowLength * cos(angle + arrowAngle),
            y: midPoint.y - arrowLength * sin(angle + arrowAngle)
        )
        
        var arrowPath = Path()
        arrowPath.move(to: leftPoint)
        arrowPath.addLine(to: midPoint)
        arrowPath.addLine(to: rightPoint)
        
        context.stroke(arrowPath, with: .color(color), lineWidth: 1.5)
    }
    
    private static func drawVectorLine(from startingPoint: CGPoint, to endPoint: CGPoint, color: Color, in context: GraphicsContext) { // Creating successive points following sinus func and add them to line path
        let dx = endPoint.x - startingPoint.x
        let dy = endPoint.y - startingPoint.y
        let length = sqrt(dx * dx + dy * dy)
        let angle = atan2(dy, dx)
        
        let amplitude: CGFloat = 4
        let wavelength: CGFloat = 12
        
        var path = Path()
        let steps = max(Int(length / 2), 1)
        path.move(to: startingPoint)
        
        for i in 1...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let distanceAlong = t * length
            let perpendicularOffset = amplitude * sin(2 * .pi * distanceAlong / wavelength)
            
            let baseX = startingPoint.x + distanceAlong * cos(angle)
            let baseY = startingPoint.y + distanceAlong * sin(angle)
            let offsetX = baseX - perpendicularOffset * sin(angle)
            let offsetY = baseY + perpendicularOffset * cos(angle)
            
            path.addLine(to: CGPoint(x: offsetX, y: offsetY))
        }
        
        context.stroke(path, with: .color(color), lineWidth: 1.5)
        
    }
    
    private static func drawGluonLine(from startingPoint: CGPoint, to endPoint: CGPoint, color: Color, in context: GraphicsContext) {
        let dx = endPoint.x - startingPoint.x
        let dy = endPoint.y - startingPoint.y
        let length = sqrt(dx * dx + dy * dy)
        let angle = atan2(dy, dx)
        
        let radius: CGFloat = 7
        let loopsCount: CGFloat = max(length / 15, 1)
        let advancePerRadian = length / (loopsCount * .pi * 2)
        let steps = max(Int(loopsCount * 40), 1)
        
        var path = Path()
        path.move(to: startingPoint)
        
        for i in 0...steps {
            let t = CGFloat(i)  / CGFloat(steps) * loopsCount * 2 * .pi
            
            let localX = advancePerRadian * t + radius * cos(t)
            let localY = radius * sin(t)
            
            let worldX  = startingPoint.x + localX * cos(angle) - localY * sin(angle)
            let worldY  = startingPoint.y + localX * sin(angle) + localY * cos(angle)
            
            
            
            let point = CGPoint(x: worldX, y: worldY)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            context.stroke(path, with: .color(color), lineWidth: 1.5)
        }
    }
}

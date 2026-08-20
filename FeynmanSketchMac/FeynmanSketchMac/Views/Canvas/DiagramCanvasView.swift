//
//  DiagramCanvasView.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 10/08/2026.
//

import SwiftUI
import DiagramModel

struct DiagramCanvasView: View {
    @ObservedObject var editor: DiagramEditorViewModel
    @ObservedObject var toolbox: ToolboxViewModel
    
    @State private var draggedLineID: PropagatorLine.ID?
    
    var body: some View {
        Canvas {context, size in
            GridOverlay.draw(in: context, size: size, spacing: CGFloat(editor.gridSpacing))
            drawLines(in: context)
            drawVertices(in: context)
            if toolbox.activeTool == .curvature {
                drawCurvatureHandles(in: context)
            }
        }
        .onTapGesture {location in
            handleTap(at: location)
        }
        .gesture(
            toolbox.activeTool == .curvature ?
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    handleCurvatureDrag(value)
                }
                .onEnded { _ in
                    draggedLineID = nil
                }
            : nil
    
        )
        .onChange(of: toolbox.activeTool) {
            editor.selection = nil
            editor.cancelPendingLine()
        }
    }
    
    private func handleTap(at location: CGPoint) {
        let point = Point(location)
        
        switch toolbox.activeTool {
        case .vertex:
            editor.addVertex(at: point)
        case .line(let type):
            editor.beginOrCompleteLine(at: point, type: type)
        case .select:
            editor.selectElement(at: point)
        case .curvature:
            break
        }
    }
    
    private func drawVertices(in context: GraphicsContext) {
        let diameter: CGFloat = CanvasStyle.vertexDiameter
        for vertex in editor.graph.vertices {
            let center = vertex.position.cgPoint
            let rect = CGRect(
                x: center.x - diameter / 2,
                y: center.y - diameter / 2,
                width: diameter,
                height: diameter)
            
            let isHighLighted = vertex.id == editor.pendingLineStart || editor.selection == .vertex(vertex.id)
            
            context.stroke(
                Path(ellipseIn: rect),
                with: .color(isHighLighted ? .orange : .blue),
                lineWidth: 2
            )
            
            if let label = vertex.label, !label.isEmpty {
                context.draw(
                    Text(label).font(.callout),
                    at: CGPoint(x: center.x, y: center.y - diameter * 1.5)
                    )
            }
        }
    }
    
    private func drawLines(in context: GraphicsContext){
        for line in editor.graph.lines {
            guard let start = editor.graph.vertex(withID: line.startVertexID),
                  let end = editor.graph.vertex(withID: line.endVertexID) else { continue }
            
            let isSelected = editor.selection == .line(line.id)
            let color: Color = isSelected ? .orange : .black
            let startPoint = start.position.cgPoint
            let endPoint = end.position.cgPoint
            
            LineStyleRenderer.draw(line.type, from: startPoint, to: endPoint, curvatureDegrees: line.curvature, color: color, in: context)
            
            if let label = line.label, !label.isEmpty {
                let midPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
                context.draw(Text(label).font(.callout), at: CGPoint(x: midPoint.x, y: midPoint.y - 15))
                
            }
        }
    }
    
    private func drawCurvatureHandles(in context: GraphicsContext) {
        let handleDiameter: CGFloat = CanvasStyle.curvaturehandleDiameter
        for line in editor.graph.lines {
            guard let start = editor.graph.vertex(withID: line.startVertexID),
                    let end = editor.graph.vertex(withID: line.endVertexID) else { continue }
            let midPoint = ArcGeometry.midpointOfArc(from: start.position.cgPoint, to: end.position.cgPoint, curvatureDegrees: line.curvature)
            
            let rect = CGRect(
                x: midPoint.x - handleDiameter / 2,
                y: midPoint.y - handleDiameter / 2,
                width: handleDiameter,
                height: handleDiameter
            )
            
            context.fill(Path(ellipseIn: rect), with: .color(.purple.opacity(0.8)))
        }
    }
    
    private func lineWithControlPoint(near point: CGPoint, tolerance: CGFloat = 12) -> PropagatorLine.ID? {
        var closestLineID: PropagatorLine.ID?
        var closestDistance = CGFloat.infinity
        
        for line in  editor.graph.lines {
            guard let start = editor.graph.vertex(withID: line.startVertexID),
                  let end = editor.graph.vertex(withID: line.endVertexID) else { continue }
            
            let midPoint = ArcGeometry.midpointOfArc(from: start.position.cgPoint, to: end.position.cgPoint, curvatureDegrees: line.curvature)
            let distance = hypot(midPoint.x - point.x, midPoint.y - point.y)
            
            if distance < closestDistance {
                closestDistance = distance
                closestLineID = line.id
            }
        }
        guard closestDistance <= tolerance else { return nil }
        return closestLineID
    }
    
    private func handleCurvatureDrag(_ value: DragGesture.Value) {
        let lineID: PropagatorLine.ID
        if let existing = draggedLineID {
            lineID = existing
        } else {
            guard let found = lineWithControlPoint(near: value.startLocation) else { return }
            draggedLineID = found
            lineID = found
            
        }
        guard let line = editor.graph.lines.first(where: { $0.id == lineID }),
              let start = editor.graph.vertex(withID: line.startVertexID),
              let end = editor.graph.vertex(withID: line.endVertexID) else { return }
        
        let startPoint = start.position.cgPoint
        let endPoint = end.position.cgPoint
        
        let length = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y)
        
        let sagitta = ArcGeometry.projectedOffset(mouseLocation: value.location, start: startPoint, end: endPoint)
        var degrees = ArcGeometry.curvatureDegrees(forSagitta: sagitta, length: Double(length))
        degrees = ArcGeometry.snappedCurvature(degrees)
        
        editor.setCurvature(degrees, forLine: lineID)
    }
}

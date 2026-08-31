//
//  DiagramCanvasView.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 10/08/2026.
//

import SwiftUI
import DiagramModel

/// The canvas where the diagram is drawn and edited.
///
/// This view is the bridge between user interaction and the two ViewModels: it reads ``ToolboxViewModel/activeTool`` to decide what a gesture should do and calls the corresponding method on ``DiagramEditorViewModel``. The two ViewModels then remain independent from each other.
struct DiagramCanvasView: View {
    /// The diagram editor this canvas reads and acts on.
    @ObservedObject var editor: DiagramEditorViewModel
    /// The toolbox this canvas reads the active tool from.
    @ObservedObject var toolbox: ToolboxViewModel
    /// The line currently being dragged, if any.
    ///
    /// Set on the first `.onChanged` of a drag, and used for subsequent updates.
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
    
    /// Executes the correct action for a user's tap, based on the active tool.
    ///  - Parameter location: the tapped location, in the canvas' local coordinate system.
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
    
    /// Draws every vertex in the current diagram, highlighting the one involved in an in-progress line, or currently selected.
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
    
    /// Draws every line of the current diagram, using ``LineStyleRenderer`` for the visual style and highlighting the currently selected line, if any.
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
    
    /// Draws a small draggable handle on each line of the current diagram, visible only when the `.curvature` tool is active.
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
    
    /// Finds the line whose curvature control point is closest to a given location, within tolerance.
    ///
    /// This has to be separated from ``HitTester`` as the curvature control point is an UI-only concept, it is never a valid ``Selection``.
    ///  - Parameters:
    ///         - point: the location to test proximity against.
    ///         - tolerance: the maximum distance within which a control point is considered to be tapped on.
    /// - Returns: the identifier of the line corresponding to the aimed control point, or `nil` if no control point falls within tolerance.
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
    
    /// Handles updates of the curvature drag gesture.
    ///
    /// On the first call of the drag gesture, locates which control point is dragged and remembers it in ``draggedLineID``, so subsequent calls keep updating the same line even if the cursor drifts away from the control point.
    /// - Parameter value: the current state of the drag gesture.
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

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
    
    var body: some View {
        Canvas {context, size in
            drawLines(in: context)
            drawVertices(in: context)
        }
        .onTapGesture {location in
            handleTap(at: location)
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
        }
    }
    
    private func drawVertices(in context: GraphicsContext) {
        let diameter: CGFloat = 10
        for vertex in editor.graph.vertices {
            let center = vertex.position.cgPoint
            let rect = CGRect(
                x: center.x - diameter / 2,
                y: center.y - diameter / 2,
                width: diameter,
                height: diameter)
            
            let isSelected = vertex.id == editor.pendingLineStart
            context.stroke(
                Path(ellipseIn: rect),
                with: .color(isSelected ? .orange : .blue),
                lineWidth: 2
            )
        }
    }
    
    private func drawLines(in context: GraphicsContext){
        for line in editor.graph.lines {
            guard let start = editor.graph.vertex(withID: line.startVertexID),
                  let end = editor.graph.vertex(withID: line.endVertexID) else { continue }
            
            var path = Path()
            path.move(to: start.position.cgPoint)
            path.addLine(to: end.position.cgPoint)
            
            context.stroke(path, with: .color(.black), lineWidth: 1.5)
        }
    }
}

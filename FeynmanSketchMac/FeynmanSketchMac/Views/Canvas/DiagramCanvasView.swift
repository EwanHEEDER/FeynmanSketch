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
            GridOverlay.draw(in: context, size: size, spacing: CGFloat(editor.gridSpacing))
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
            
            LineStyleRenderer.draw(line.type, from: startPoint, to: endPoint, color: color, in: context)
            
            if let label = line.label, !label.isEmpty {
                let midPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
                context.draw(Text(label).font(.callout), at: CGPoint(x: midPoint.x, y: midPoint.y - 15))
                
            }
        }
    }
    
    
}

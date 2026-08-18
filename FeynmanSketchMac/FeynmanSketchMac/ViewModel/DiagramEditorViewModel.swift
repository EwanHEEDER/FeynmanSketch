//
//  DiagramEditorViewModel.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 06/08/2026.
//

import DiagramModel
import Combine


@MainActor
final class DiagramEditorViewModel: ObservableObject {

    @Published var graph: DiagramGraph
    @Published var selection: Selection?
    
    @Published private(set) var pendingLineStart: Vertex.ID?
    private let hitTester = HitTester()
    let gridSpacing: Double = 20
    
    var selectionLabel: String? {
        guard let selection else { return nil }
        switch selection {
        case .vertex(let vertexID):
            return graph.vertex(withID: vertexID)?.label
        case .line(let lineID):
            return graph.lines.first(where: { $0.id == lineID})?.label
        }
    }

    init(graph: DiagramGraph = DiagramGraph()) {
        self.graph = graph
    }
    
    func reset() {
        graph = DiagramGraph()
        selection = nil
        pendingLineStart = nil
    }
    
    func addVertex(at point: Point) {
        graph.addVertex(at: snapped(point))
    }
    
    func selectElement(at point: Point) {
        selection = hitTester.selection(in: graph, near: point)
    }
    
    func beginOrCompleteLine(at point: Point, type: LineType) -> PropagatorLine? { // If vertex is already selected, add new line to graph, else add this veretx as pending selection
        guard let hitResult = hitTester.selection(in: graph, near: point) else {
            return nil
        }
        
        guard case .vertex(let tappedVertexID) = hitResult else {
            return nil
        }
        
        guard let startID = pendingLineStart else {
            // No pending Start ID -> Create one and return nil
            pendingLineStart = tappedVertexID
            return nil
        }
        
        pendingLineStart = nil
        
        guard startID != tappedVertexID else {
            return nil
        }
        
        return graph.addLine(startVertexID: startID, endVertexID: tappedVertexID, type: type)
    }
    
    func deleteSelection() {
        guard let selection else { return }
        switch selection {
        case .line(let lineID):
            graph.removeLine(withID: lineID)
        case .vertex(let vertexID):
            graph.removeVertex(withID: vertexID)
        }
        
        self.selection = nil
    }
    
    func cancelPendingLine() {
        pendingLineStart = nil
    }
    
    private func snapped(_ point: Point) -> Point { // Snap given point to closest grid node
        Point(
            x: (point.x / gridSpacing).rounded() * gridSpacing,
            y: (point.y / gridSpacing).rounded() * gridSpacing
        )
    }
    
    func setLabelOnSelection(_ label: String) { // Used by "Label" button to change label of selected element
        guard let selection else { return }
        switch selection {
        case .vertex(let vertexID):
            guard let index = graph.vertices.firstIndex(where: {$0.id == vertexID}) else { return }
            graph.vertices[index].label = label
        case .line(let lineID):
            guard let index = graph.lines.firstIndex(where: {$0.id == lineID}) else { return }
            graph.lines[index].label = label
        }
    }
    
    func setCurvature(_ degrees: Double, forLine lineID: PropagatorLine.ID) {
        guard let index = graph.lines.firstIndex(where: { $0.id == lineID }) else { return }
        graph.lines[index].curvature = degrees
    }
}

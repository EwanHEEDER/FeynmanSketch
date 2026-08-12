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

    init(graph: DiagramGraph = DiagramGraph()) {
        self.graph = graph
    }
    
    func addVertex(at point: Point) {
        graph.addVertex(at: point)
    }
    
    func selectElement(at point: Point) {
        selection = hitTester.selection(in: graph, near: point)
    }
    
    func beginOrCompleteLine(at point: Point, type: LineType) -> PropagatorLine? {
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
}

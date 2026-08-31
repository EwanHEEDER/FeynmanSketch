//
//  DiagramEditorViewModel.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 06/08/2026.
//

import DiagramModel
import DiagramConversion
import Combine

/// The central view model for diagram editing: owns the ``DiagramGraph`` being edited, tracks selection and in-progress interactions, and exposes every action the canvas can trigger.
///
/// In order to keep this model independent from ``ToolboxViewModel``,   the active drawing tool is left outside of the scope of this view model, and is just read.
@MainActor
final class DiagramEditorViewModel: ObservableObject {

    /// The diagram currently being edited
    @Published var graph: DiagramGraph
    /// The element currently selected with the `.select` tool, if any
    @Published var selection: Selection?
    
    /// the vertex a line is currently being drawn from, while the `.line` tool is in the middle of the two-tap gesture. `nil` when no line is being drawn.
    @Published private(set) var pendingLineStart: Vertex.ID?
    
    private let hitTester = HitTester()
    
    /// The spacing between grid nodes, in screen points. Used both from snapping new vertices and drawing the grid overlay.
    let gridSpacing: Double = 20
    
    /// Label of the current selection (vertex or line), or `nil` if nothing is selected / the selection has no label.
    var selectionLabel: String? {
        guard let selection else { return nil }
        switch selection {
        case .vertex(let vertexID):
            return graph.vertex(withID: vertexID)?.label
        case .line(let lineID):
            return graph.lines.first(where: { $0.id == lineID})?.label
        }
    }
    
    /// Typst source code corresponding to the current diagram, scaled from screen points down to grid units.
    var generatedTypstCode: String {
        let scaledGraph = scaleForExport(graph)
        return TypstCodeGenerator().generate(from: scaledGraph)
    }

    init(graph: DiagramGraph = DiagramGraph()) {
        self.graph = graph
    }
    
    /// Clears the diagram entirely: all vertices and lines. Resets the current selection.
    ///
    /// Cannot be undone.
    func reset() {
        graph = DiagramGraph()
        selection = nil
        pendingLineStart = nil
    }
    
    
    /// Adds a new vertex at the given position , snapped to the closest grid node.
    ///
    ///  - Parameter point: the tapped position, in screen points.
    func addVertex(at point: Point) {
        graph.addVertex(at: snapped(point))
    }
    
    /// Updates ``selection`` to whatever is closest to the given point, or `nil` if nothing is close enough.
    ///  - Parameter point: the tapped position, in screen points.
    func selectElement(at point: Point) {
        selection = hitTester.selection(in: graph, near: point)
    }
    
    /// Handles one tap of the two-tap line-drawing gesture.
    /// The first tap on a vertex stores it as ``pendingLineStart`` and returns `nil`. The second tap on a *different* vertex creates a line between the two vertices and returns it, and sets ``pendingLineStart`` back to `nil`. Tapping the same vertex twice cancels the in-progress line. Tapping anywhere else than a vertex is ignored.
    /// - Parameters:
    ///         - point: the tapped position, in screen points.
    ///         - type: the line type to create.
    /// - Returns: the newly created line, or `nil` if this tap started, canceled or missed the creation.
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
    
    /// Deletes the currently selected vertex or line, if any, and clears ``selection``.
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
    
    /// Cancels any line currently in progress, resetting ``pendingLineStart`` to `nil`.
    ///
    /// Called whenever the active tool is switched, so line cannot be started in one drawing style and finished with another.
    func cancelPendingLine() {
        pendingLineStart = nil
    }
    
    /// Rounds a position to the nearest grid node, based on ``gridSpacing``.
    private func snapped(_ point: Point) -> Point { // Snap given point to closest grid node
        Point(
            x: (point.x / gridSpacing).rounded() * gridSpacing,
            y: (point.y / gridSpacing).rounded() * gridSpacing
        )
    }
    
    /// Sets the label of the currently selected object, if any.
    ///  - Parameter label: the new label text.
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
    
    /// Sets the curvature of a specific line, by ID.
    ///  - Parameters:
    ///         - degrees: the new curvature, in degrees.
    ///         - lineID: ID of the line to update.
    func setCurvature(_ degrees: Double, forLine lineID: PropagatorLine.ID) {
        guard let index = graph.lines.firstIndex(where: { $0.id == lineID }) else { return }
        graph.lines[index].curvature = degrees
    }
    
    /// Produces a copy of a graph with every vertex position divided by ``gridSpacing``.
    ///
    /// The conversion only happens at export time, in ``generatedTypstCode``, leaving untouched the graph used for editing.
    /// - Parameter graph: the graph to scale down.
    /// - Returns: a new graph, with the same structure, but with vertex positions expressed in grid units instead of screen points.
    private func scaleForExport(_ graph: DiagramGraph) -> DiagramGraph {
        var scaled = graph
        
        for i in scaled.vertices.indices {
            scaled.vertices[i].position.x /= gridSpacing
            scaled.vertices[i].position.y /= gridSpacing
        }
        
        return scaled
    }
}

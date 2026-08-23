import Foundation
/// Complete model of a Feynman diagram: a set of vertices connected by propagator lines.
///
/// To ensure the maximal freedom in diagram creation, only referential intrity is guaranteed: a line can only be created between existing vertices, and removing a vertex automatically removes the propagator lines it's connected to. Beyong this, no physical validation is performed. The only purpose is to provide a structural model for diagram editing and  rendering.
public struct DiagramGraph: Codable, Equatable {
    /// All vertices currently in the diagram.
    public var vertices: [Vertex]
    /// All propagator lines currently in the diagram.
    public var lines: [PropagatorLine]

    public init(vertices: [Vertex] = [], lines: [PropagatorLine] = []) {
        self.vertices = vertices
        self.lines = lines
    }
    
    /// Looks up a vertex by its ID.
    /// - Parameter id: the vertex's identifier.
    /// - Returns: the matching vertex if found in the list, `nil` if not existing.
    public func vertex(withID id: Vertex.ID) -> Vertex? {
        return vertices.first(where: { $0.id == id })
    }

    /// Adds a new vertex to the graph.
    /// - Parameters:
    ///         - position: The new vertex's position in graph.
    ///         - label: Optional label for the new vertex.
    /// - Returns: the newly created vertex, not necessarily used.
    @discardableResult
    public mutating func addVertex(
        at position: Point,
        label: String? = nil
    ) -> Vertex {

        let newVertex = Vertex(
            position: position,
            label: label)

        self.vertices.append(newVertex)

        return newVertex
    }

    /// Adds a new line between two existing vertices.
    ///
    /// Fails and returns `nil` if any of the two specified vertices does not already exist in the graph.
    /// - Parameters:
    ///            - startVertexID: ID of the vertex from wich the new line starts.
    ///            - endVertexID: ID of the vertex to which the new line ends.
    ///            - type: Drawing style of the new line.
    ///            - label: Optional label for the new line.
    ///            - curvature: Curvature of the new line, in degrees. Default to 0° (straight line).
    /// - Returns: The new line if both starting and ending vertices have been found in the graph's existing vertices, `nil`if either of them in unkown.
    @discardableResult
    public mutating func addLine(
        startVertexID: Vertex.ID,
        endVertexID: Vertex.ID,
        type: LineType,
        label: String? = nil,
        curvature: Double = 0.0
    ) -> PropagatorLine? {  // First check both start and end vertices exist in the graph
        guard vertex(withID: startVertexID) != nil else {
            return nil
        }
        guard vertex(withID: endVertexID) != nil else {
            return nil
        }

        let newLine = PropagatorLine(
            id: UUID(),
            startVertexID: startVertexID,
            endVertexID: endVertexID,
            type: type,
            label: label,
            curvature: curvature
        )

        self.lines.append(newLine)

        return newLine
    }

    /// If a given line exists in the graph, removes it.
    /// - Parameter id: The ID of the line to remove.
    public mutating func removeLine(withID id: PropagatorLine.ID) {
        self.lines.removeAll(where: { $0.id == id })
    }

    /// If a vertex exists in the graph, removes it and every lines connected to it.
    /// - Parameter id: ID of the vertex to remove.
    public mutating func removeVertex(withID id: Vertex.ID) {  // If the removed vertex is connected to any line, they should also be removed
        self.vertices.removeAll(where: { $0.id == id })
        self.lines.removeAll(where: { $0.startVertexID == id || $0.endVertexID == id })
    }

    /// Finds all lines connected to a given vertex
    ///
    /// - Parameter vertexID: ID of the vertex to look up connections for.
    /// - Returns: every line whose `startVertexID` or `endVertexID` matches to `vertexID`.
    public func lines(connectedTo vertexID: Vertex.ID) -> [PropagatorLine] {
        return self.lines.filter { $0.startVertexID == vertexID || $0.endVertexID == vertexID }
    }

    /// Determines if a vertex is internal or external based on the diagram topology, using the number of lines connected to it
    ///
    /// As it can evolve depending on the user's action, this property is never attached to the ``Vertex`` object itself, but recomputed when needed. See ``VertexRole`` for the possible roles and their meaning.
    /// - Parameter vertexID: ID of the vertex to determine the role of.
    /// - Returns: Current role of this vertex: `.isolated` if no line is connected, `.incoming`/`.outgoing` if exactly one line is connected, and `.interior` if two or more lines are connected.
    public func role(of vertexID: Vertex.ID) -> VertexRole {
        let connectedLines = lines(connectedTo: vertexID)

        if connectedLines.count >= 2 { return .interior }
        guard let only = connectedLines.first else { return .isolated }
        return only.startVertexID == vertexID ? .incoming : .outgoing
    }

}

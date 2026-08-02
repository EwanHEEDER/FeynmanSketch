import Foundation

public struct DiagramGraph: Codable, Equatable {
    public var vertices: [Vertex]
    public var lines: [PropagatorLine]

    public init(vertices: [Vertex] = [], lines: [PropagatorLine] = []) {
        self.vertices = vertices
        self.lines = lines
    }

    public func vertex(withID id: Vertex.ID) -> Vertex? {
        return vertices.first(where: { $0.id == id })
    }

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

    public mutating func removeLine(withID id: PropagatorLine.ID) {
        self.lines.removeAll(where: { $0.id == id })
    }

    public mutating func removeVertex(withID id: Vertex.ID) {  // If the removed vertex is connected to any line, they should also be removed
        self.vertices.removeAll(where: { $0.id == id })
        self.lines.removeAll(where: { $0.startVertexID == id || $0.endVertexID == id })
    }

    public func lines(connectedTo vertexID: Vertex.ID) -> [PropagatorLine] {
        return self.lines.filter { $0.startVertexID == vertexID || $0.endVertexID == vertexID }
    }

    public func role(of vertexID: Vertex.ID) -> VertexRole {
        let connectedLines = lines(connectedTo: vertexID)

        if connectedLines.count >= 2 { return .interior }
        guard let only = connectedLines.first else { return .isolated }
        return only.startVertexID == vertexID ? .incoming : .outgoing
    }

}

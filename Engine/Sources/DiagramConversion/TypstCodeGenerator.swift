import DiagramModel

public struct TypstCodeGenerator {
    public var fletcherVersion: String

    public init(fletcherVersion: String = "0.5.8") {
        self.fletcherVersion = fletcherVersion
    }

    public func generate(from graph: DiagramGraph) -> String {

        var code = ""

        // build dictionnary of internal and externalvertices

        let internalVertexIDs = Set(graph.vertices.filter(\.isInternal).map(\.id))

        func isInternalLine(_ line: PropagatorLine) -> Bool {
            return internalVertexIDs.contains(line.startVertexID) && internalVertexIDs.contains(line.endVertexID)
        }

        var internalVertices: [Vertex.ID: String] = [:]
        var externalVertices: [Vertex.ID] = []

        for vertex in graph.vertices {
            if vertex.isInternal {
                internalVertices[vertex.id] = "v\(internalVertices.count + 1)"
            } else {
                    externalVertices.append(vertex.id)
                }
        }

        var internalLines: [PropagatorLine] = []
        var externalLines: [PropagatorLine] = []

        for line in graph.lines {
            if isInternalLine(line) {
                internalLines.append(line)
            } else {
                externalLines.append(line)
            }
        }

        return code
    }

    private func coordinateLiteral(_ point: Point) -> String { // returns a string representation of a point in the format "(x, y)"
        return "(\(point.x), \(point.y))"
    }

    private func header() -> String {
        return """
            // Generated with FeynmanSketch alpha version

            #import \"@preview/fletcher:\(fletcherVersion)\" as fletcher: diagram, node, edge

            #diagram (
                spacing: 1.8em,
            """
    }

}

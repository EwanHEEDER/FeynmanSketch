import DiagramModel

public struct TypstCodeGenerator {
    public var fletcherVersion: String

    public init(fletcherVersion: String = "0.5.8") {
        self.fletcherVersion = fletcherVersion
    }

    public func generate(from graph: DiagramGraph) -> String {

        // build names dictionnary for vertices based on role in the graph
        var names : [Vertex.ID: String] = [:]
        var incomingCount = 0
        var outgoingCount = 0
        var isolatedCount = 0
        var interiorCount = 0

        for vertex in graph.vertices {
            switch graph.role(of: vertex.id) {
            case .incoming:
                incomingCount += 1
                names[vertex.id] = "i\(incomingCount)"
            case .outgoing:
                outgoingCount += 1
                names[vertex.id] = "o\(outgoingCount)"
            case .isolated:
                isolatedCount += 1
                names[vertex.id] = "e\(isolatedCount)"
            case .interior:
                interiorCount += 1
                names[vertex.id] = "v\(interiorCount)"
            }
        }

        var lines: [String] = [header(from: graph)]

        if graph.vertices.isEmpty { // Empty diagram, just close the block
            lines.append(")")
            return lines.joined(separator: "\n")
        }

         // Will contain the lines of typst code to be returned

        let externalVertices = graph.vertices.filter {graph.role(of: $0.id) != .interior}
        let internalVertices = graph.vertices.filter {graph.role(of: $0.id) == .interior}

        let externalLines = graph.lines.filter { line in
            let startRole = graph.role(of: line.startVertexID)
            let endRole = graph.role(of: line.endVertexID)
            return startRole != .interior || endRole != .interior
        }

        let internalLines = graph.lines.filter { line in
            let startRole = graph.role(of: line.startVertexID)
            let endRole = graph.role(of: line.endVertexID)
            return startRole == .interior && endRole == .interior
        }

        // Node statements for external vertices

        if !externalVertices.isEmpty {
            lines.append(" // External vertices")
            for vertex in externalVertices {
                lines.append(nodeStatement(for: vertex, role: graph.role(of: vertex.id), names: names))
            }
        }

        // For internal

        if !internalVertices.isEmpty {
            lines.append(" // Internal vertices")
            for vertex in internalVertices {
                lines.append(nodeStatement(for: vertex, role: graph.role(of: vertex.id), names: names))
            }
        }

        // Edge statements for external lines 

        if !externalLines.isEmpty {
            lines.append(" // External lines")
            for line in externalLines {
                lines.append(edgeStatement(for: line, in: graph, names: names))
            }
        }

        // Edge statements for internal lines

        if !internalLines.isEmpty {
            lines.append(" // Internal lines")
            for line in internalLines {
                lines.append(edgeStatement(for: line, in: graph, names: names))
            }
        }

        // Properly close the diagram typst block
        lines.append(")")

        return lines.joined(separator: "\n")
    }

    private func coordinateLiteral(_ point: Point) -> String { // returns a string representation of a point in the format "(x, y)"
        return "(\(point.x), \(point.y))"
    }

    private func reference(for vertex: Vertex, names: [Vertex.ID: String]) -> String {
        return "<\(names[vertex.id] ?? "?")>"
    }

    private func nodeStatement(for vertex: Vertex, role: VertexRole, names: [Vertex.ID: String]) -> String {
        let name = names[vertex.id] ?? "?"
        switch role {
            case .interior:
                return "node(\(coordinateLiteral(vertex.position)), name: <\(name)>, radius: 2pt, fill: black),"
            case .incoming, .outgoing, .isolated:
                let content = vertex.label.map { "$\($0)$" } ?? "[]"
                return "node(\(coordinateLiteral(vertex.position)), \(content), name: <\(name)>),"
        }
    }

    private func edgeStatement(for line: PropagatorLine, in graph: DiagramGraph, names: [Vertex.ID: String]) -> String {
        guard let start = graph.vertex(withID: line.startVertexID),
              let end = graph.vertex(withID: line.endVertexID) else {
            return "// Skipped, unknown vertex reference"
        }
        // Construct proper argument chain for the eddge statement, depending on line type

        var args: [String] = [
            reference(for: start, names: names),
            reference(for: end, names: names)
        ]

        if let label = line.label, !label.isEmpty {
            args.append("$\(label)$")
        }

        args.append("\"\(FletcherSyntax.markArgument(for: line.type))\"")

        if let decorations = FletcherSyntax.decorations(for: line.type) {
            args.append("decorations: \"\(decorations)\"")
        }

        args.append(contentsOf: FletcherSyntax.extraEdgeArguments(for: line.type))

        if line.curvature != 0.0 {
            args.append("bend: \(line.curvature)deg")
        }

        return "edge(\(args.joined(separator: ", "))),"
    }

    private func header(from diagram: DiagramGraph) -> String {

        if diagram.vertices.isEmpty {
            return """
            // Generated with FeynmanSketch alpha version

            #import \"@preview/fletcher:\(fletcherVersion)\" as fletcher: diagram, node, edge

            #diagram(
                spacing: 1.8em
            """
        } else {
            return """
            // Generated with FeynmanSketch alpha version

            #import \"@preview/fletcher:\(fletcherVersion)\" as fletcher: diagram, node, edge

            #diagram(
                spacing: 1.8em,
            """
        }

    }
}
import DiagramModel

/// Converts a ``DiagramGraph`` into Typst source code that uses the fletcher package.

public struct TypstCodeGenerator {
    /// The version of Typst's fletcher package to call. Set by default to "0.5.8", which is known to work and for which this app has been tested. It is recommended not to change unless very specific needs.
    public var fletcherVersion: String

    public init(fletcherVersion: String = "0.5.8") {
        self.fletcherVersion = fletcherVersion
    }

    /// Generates the typst code corresponding to a given ``DiagramGraph``.
    ///
    /// Code generation is separated in three steps: a header containing package imports and the call to `#diagram` function with general arguments, loops over graph vertices and lines (separated between internal and external to make the final code easier to read/modify) and closure of the `#diagram` function.
    /// - Parameter graph: Instance of ``DiagramGraph`` for which the corresponding Typst code will be produced.
    /// - Returns: The corresponding code, as a formatted string.
    public func generate(from graph: DiagramGraph) -> String {

        // build names dictionary for vertices based on role in the graph
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

    /// Helper function for generating formated coordinate reference.
    /// - Parameter point: The point that the Typst statement will refer to.
    /// - Returns: This point coordinates in the form of a string `"(x, y)"`.
    private func coordinateLiteral(_ point: Point) -> String { // returns a string representation of a point in the format "(x, y)"
        return "(\(point.x), \(point.y))"
    }

    /// Helper function for generating formated vertex reference.
    ///
    /// Vertices names are generated in the form of a letter referencing its role and a number incrementing for each vertex of the same role. These names are stored in a dictionary with vertex ID as key. If the vertex is not found in the name dictionary, returns a generic `"<?>"` that might block code compilation, but can be manually corrected.
    /// - Parameters:
    ///         - vertex: The ``Vertex`` instance that the Typst statement will refer to
    ///         - names: The name dictionary associated to this graph
    /// - Returns: A proper reference to this vertex in the form of a string, e.g `"<v4>"` for the fourth  vertex with `.internal` role.
    private func reference(for vertex: Vertex, names: [Vertex.ID: String]) -> String {
        return "<\(names[vertex.id] ?? "?")>"
    }

    /// Produces the general fletcher syntax for a new graph node from a given vertex.
    ///
    /// External vertices are just added as nodes that can be refered to when generating an edge, but are not graphically represented on the diagram. Internal vertices are displayed as 2pt radius circles, filled in black, in order to make visible every interaction point.
    /// - Parameters:
    ///         - vertex: The vertex whose statement will be added to the Typst code.
    ///         - role: The role of this vertex.
    ///         - names: The name dictionary associated to this graph.
    /// - Returns: A string of the formated statement adding this vertex to the compiled diagram, with appropriate graphic style depending on its role.
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

    /// Produces the general fletcher syntax for a new graph edge from a given line.
    ///
    /// Assembles the arguments corresponding to the line type to build a proper fletcher`edge()` statement. Includes a validity check for the line (existing start/end).
    /// - Parameters:
    ///         - line: The line whose statement will be added to the Typst code.
    ///         - graph: The ``DiagramGraph`` instance that will be converted, in order to check line validity.
    ///         - names: The name dictionary associated to this graph.
    /// - Returns: A string of the formated statement adding this line to the compiled diagram, with requiered arguments associated to its line type.
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

    /// The general header of the generated Typst code. Contains the fletcher import with correct version, and the call to `#diagram` function. If diagram is empty, returns a version without final comma, so that the Typst function can be closed without trailing comma error.
    /// - Parameter diagram: The ``DiagramGraph`` instance that will be converted, in order to check if its vertex list is empty.
    /// - Returns: A string of the Typst code header.
    private func header(from diagram: DiagramGraph) -> String {

        if diagram.vertices.isEmpty {
            return """
            // Generated with FeynmanSketch beta version

            #import \"@preview/fletcher:\(fletcherVersion)\" as fletcher: diagram, node, edge

            #diagram(
                spacing: 1.8em
            """
        } else {
            return """
            // Generated with FeynmanSketch beta version

            #import \"@preview/fletcher:\(fletcherVersion)\" as fletcher: diagram, node, edge

            #diagram(
                spacing: 1.8em,
            """
        }

    }
}

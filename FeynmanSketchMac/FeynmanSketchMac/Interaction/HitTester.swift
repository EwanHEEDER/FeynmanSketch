//
//  HitTester.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 06/08/2026.
//

import DiagramModel

/// Determines what, if anything, is close enough to a given point to count as a tap or click target, either a vertex or a line.
///
/// Vertices are tested before lines: if a point falls within tolerance of both a vertex and a line, the point will be returned before the line is even tested.
/// Among vertices, the closest one is chosen, all vertices are tested.
struct HitTester {
    /// The maximum distance for an element to be considered hit, expressed in the same unit as the points (screen points, not canvas grid units).
    var tolerance: Double
    
    init (tolerance: Double = 15) {
        self.tolerance = tolerance
    }
    /// Finds the closest vertex or line to a given point, within ``tolerance``.
    /// - Parameters:
    ///         - graph: The graph to search within.
    ///         - point: The point to test.
    /// - Returns: a ``Selection`` for the closest matching vertex or line, or `nil` if no element is found within tolerance.
    func selection(in graph: DiagramGraph, near point: Point) -> Selection? {
        var closestVertex: Vertex?
        var closestVertexDistance: Double = Double.infinity
        
        for vertex in graph.vertices {
            let distance = point.distance(to: vertex.position)
            if distance < closestVertexDistance {
                closestVertexDistance = distance
                closestVertex = vertex
            }
        }
        if let closestVertex, closestVertexDistance <= tolerance {
            return .vertex(closestVertex.id)
        }
        // If no vertex is found, search lines
        
        var closestLine: PropagatorLine?
        var closestLineDistance: Double = Double.infinity
        
        for line in graph.lines {
            guard let start = graph.vertex(withID: line.startVertexID),
                  let end = graph.vertex(withID: line.endVertexID) else { continue }
            let distance = point.distance(toSegmentFrom: start.position, to: end.position)
            if distance < closestLineDistance {
                closestLineDistance = distance
                closestLine = line
            }
        }
        if let closestLine, closestLineDistance <= tolerance {
            return .line(closestLine.id)
        }
        
        return nil
    }
}

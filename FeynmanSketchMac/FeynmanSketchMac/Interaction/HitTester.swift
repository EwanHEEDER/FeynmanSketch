//
//  HitTester.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 06/08/2026.
//

import DiagramModel

struct HitTester {
    var tolerance: Double
    
    init (tolerance: Double = 15) {
        self.tolerance = tolerance
    }
    
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

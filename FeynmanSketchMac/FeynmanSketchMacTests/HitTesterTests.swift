//
//  HitTesterTests.swift
//  FeynmanSketchMacTests
//
//  Created by HEEDER Ewan on 06/08/2026.
//

import Testing
@testable import FeynmanSketchMac
@testable import DiagramModel

struct HitTesterTests {

    @Test func selectsClosestVertexAmongSeveral() {
            var graph = DiagramGraph()
            let far = graph.addVertex(at: Point(x: 0, y: 0))
            let near = graph.addVertex(at: Point(x: 0.1, y: 0))
            // le point cliqué est très proche de "near", mais encore dans la tolérance de "far" aussi

            let result = HitTester().selection(in: graph, near: Point(x: 0.12, y: 0))

            #expect(result == .vertex(near.id))
        }
    
    @Test func testReturnsNilWhenNothingIsCloseEnough() {
        var graph = DiagramGraph()
        let vertexA = graph.addVertex(at: Point(x: 0, y: 0))
        let vertexB = graph.addVertex(at: Point(x: 2, y: 0))
        
        let result = HitTester().selection(in: graph, near: Point(x: 1, y: 20))
        
        #expect(result == nil)
    }
    
    @Test func testSelectsLineWhenNoVertexIsCloseEnough() {
        var graph = DiagramGraph()
        let vertexA = graph.addVertex(at: Point(x: 0, y: 0))
        let vertexB = graph.addVertex(at: Point(x: 20, y: 0))
        let edge: PropagatorLine? = graph.addLine(startVertexID: vertexA.id, endVertexID: vertexB.id, type: .fermion)
        
        let result = HitTester().selection(in: graph, near: Point(x: 10, y: 0.1))
        
        guard let edge else {
            Issue.record("No edge found")
            return
        }
        #expect(result == .line(edge.id))
    }
    
    @Test func testPrefersVertexOverLineWhenBothAreInRange() {
        var graph = DiagramGraph()
        let vertexA = graph.addVertex(at: Point(x: 0, y: 0))
        let vertexB = graph.addVertex(at: Point(x: 3, y: 0))
        let edge: PropagatorLine? = graph.addLine(startVertexID: vertexA.id, endVertexID: vertexB.id, type: .fermion)
        
        let tolerance = HitTester().tolerance
        let testpoint: Point = Point(x: 0.1, y: 0.1)
        let result = HitTester().selection(in: graph, near: testpoint)
        
        #expect(testpoint.distance(to: vertexA.position) < tolerance)
        #expect(testpoint.distance(toSegmentFrom: vertexA.position, to: vertexB.position) < tolerance)
        #expect(result == .vertex(vertexA.id))
    }
    
    @Test func testReturnsNilOnEmptyGraph() {
        let graph = DiagramGraph()
        
        let result = HitTester().selection(in: graph, near: Point(x: 0, y: 0))
        
        #expect(result == nil)
    }
}

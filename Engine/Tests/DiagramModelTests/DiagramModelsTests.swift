import XCTest
@testable import DiagramModel

final class DiagramGraphTests: XCTestCase {
    
    func testAddLineFailsWithUnknownVertex() {
        // Given
        var graph = DiagramGraph()
        let vertex1 = graph.addVertex(at: Point(x: 0, y: 0), label: "A")

        // When
        let line = graph.addLine(
            startVertexID: vertex1.id,
            endVertexID: UUID(), // Give random UUID
            type: .scalar
        )

        // Then
        XCTAssertNil(line)
        XCTAssertEqual(graph.lines.count, 0)
    }

    func testAddLineBetweenTwoExistingVertices() {
        // Given
        var graph = DiagramGraph()
        let vertex1 = graph.addVertex(at: Point(x: 0, y: 0), label: "A")
        let vertex2 = graph.addVertex(at: Point(x: 1, y: 1), label: "B")

        // When
        let line = graph.addLine(
            startVertexID: vertex1.id,
            endVertexID: vertex2.id,
            type: .fermion,
            label: "Line AB",
            curvature: 0.5
        )

        // Then
        XCTAssertNotNil(line)
        XCTAssertEqual(line?.startVertexID, vertex1.id)
        XCTAssertEqual(line?.endVertexID, vertex2.id)
        XCTAssertEqual(line?.type, .fermion)
        XCTAssertEqual(line?.label, "Line AB")
        XCTAssertEqual(line?.curvature, 0.5)
    }

    func testRemoveVertexAlsoRemovesAssociatedLines() {
        // Given
        var graph = DiagramGraph()
        let vertex1 = graph.addVertex(at: Point(x: 0, y: 0), label: "A")
        let vertex2 = graph.addVertex(at: Point(x: 1, y: 1), label: "B")
        let line = graph.addLine(
            startVertexID: vertex1.id,
            endVertexID: vertex2.id,
            type: .fermion
        )

        XCTAssertNotNil(line)
        XCTAssertEqual(graph.lines.count, 1)

        // When
        graph.removeVertex(withID: vertex1.id)

        // Then
        XCTAssertNil(graph.vertex(withID: vertex1.id))
        XCTAssertEqual(graph.lines.count, 0)
    }

    func testDistanceBetweenRandomPointsIsAlwaysPositive() {
        // Given
        let point1 = Point(x: Double.random(in: -100...100), y: Double.random(in: -100...100))
        let point2 = Point(x: Double.random(in: -100...100), y: Double.random(in: -100...100))

        // When
        let distance = point1.distance(to: point2)

        // Then
        if point1 != point2 {
            XCTAssertGreaterThan(distance, 0)
        } else {
            XCTAssertEqual(distance, 0)
        }
    }

    func testDistanceToSegmentIsZeroForPointOnSegment() {
        // Given
        let a = Point(x: 0, y: 0)
        let b = Point(x: 2, y: 2)
        let p = Point(x: 1, y: 1) // This point lies on the segment from a to b

        // When
        let distance = p.distance(toSegmentFrom: a, to: b)

        // Then
        XCTAssertEqual(distance, 0)
    }

    func testDistanceToSegmentIsPositiveForPointOffSegment() {
        // Given
        let a = Point(x: 0, y: 0)
        let b = Point(x: 2, y: 2)
        let p = Point(x: 1, y: 2) // This point does not lie on the segment from a to b

        // When
        let distance = p.distance(toSegmentFrom: a, to: b)

        // Then
        XCTAssertGreaterThan(distance, 0)
    }

    func testDistanceToSegmentIsWellComputed() {
        // Given
        let a = Point(x: 0, y: 0)
        let b = Point(x: 4, y: 0)
        let p = Point(x: 2, y: 3) // This point is above the segment from a to b

        // When
        let distance = p.distance(toSegmentFrom: a, to: b)

        // Then
        XCTAssertEqual(distance, 3)
    }

    func testDistanceToSegmentWithZeroLengthSegmentFallsBackToPointDistance() {
    // Given
    let a = Point(x: 1, y: 1)
    let b = Point(x: 1, y: 1) // Same point: a degenerate "segment"
    let p = Point(x: 4, y: 5)

    // When
    let distance = p.distance(toSegmentFrom: a, to: b)

    // Then
    XCTAssertEqual(distance, p.distance(to: a))
}

    func testVertexRoleInterior() {
        // Given
        var graph = DiagramGraph()
        let vertex1 = graph.addVertex(at: Point(x: 0, y: 0), label: "A")
        let vertex2 = graph.addVertex(at: Point(x: 1, y: 1), label: "B")
        let vertex3 = graph.addVertex(at: Point(x: 2, y: 2), label: "C")

        // When
        _ = graph.addLine(startVertexID: vertex1.id, endVertexID: vertex2.id, type: .fermion)
        _ = graph.addLine(startVertexID: vertex2.id, endVertexID: vertex3.id, type: .fermion)

        // Then
        XCTAssertEqual(graph.role(of: vertex2.id), .interior)
    }

    func testVertexRoleIncoming() {
        // Given
        var graph = DiagramGraph()
        let vertex1 = graph.addVertex(at: Point(x: 0, y: 0), label: "A")
        let vertex2 = graph.addVertex(at: Point(x: 1, y: 1), label: "B")

        // When
        _ = graph.addLine(startVertexID: vertex1.id, endVertexID: vertex2.id, type: .fermion)

        // Then
        XCTAssertEqual(graph.role(of: vertex1.id), .incoming)
    }

    func testVertexRoleOutgoing() {
        // Given
        var graph = DiagramGraph()
        let vertex1 = graph.addVertex(at: Point(x: 0, y: 0), label: "A")
        let vertex2 = graph.addVertex(at: Point(x: 1, y: 1), label: "B")

        // When
        _ = graph.addLine(startVertexID: vertex1.id, endVertexID: vertex2.id, type: .fermion)

        // Then
        XCTAssertEqual(graph.role(of: vertex2.id), .outgoing)
    }

    func testVertexRoleIsolated() {
        // Given
        var graph = DiagramGraph()
        let vertex1 = graph.addVertex(at: Point(x: 0, y: 0), label: "A")

        // Then
        XCTAssertEqual(graph.role(of: vertex1.id), .isolated)
    }
}
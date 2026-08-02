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

}
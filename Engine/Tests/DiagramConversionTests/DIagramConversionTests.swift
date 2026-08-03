import XCTest
@testable import DiagramModel
@testable import DiagramConversion

final class DiagramConversionTests: XCTestCase {

    func testEmptyGraphStillProducesValidDiagramBlock() {
    let graph = DiagramGraph()
    let code = TypstCodeGenerator().generate(from: graph)

    XCTAssertTrue(code.contains("#import \"@preview/fletcher:"))
    XCTAssertTrue(code.hasSuffix(")"))
    }

    func testFermionLineUsesArrowMark() {
        var graph = DiagramGraph()
        let v1 = graph.addVertex(at: Point(x: 0, y: 0))
        let v2 = graph.addVertex(at: Point(x: 1, y: 0))
        graph.addLine(startVertexID: v1.id, endVertexID: v2.id, type: .fermion)

        let code = TypstCodeGenerator().generate(from: graph)
        XCTAssertTrue(code.contains("\"-|>-\""))
    }

    func testVectorLineUsesWaveDecoration() {
        var graph = DiagramGraph()
        let v1 = graph.addVertex(at: Point(x: 0, y: 0))
        let v2 = graph.addVertex(at: Point(x: 1, y: 0))
        graph.addLine(startVertexID: v1.id, endVertexID: v2.id, type: .vector)

        let code = TypstCodeGenerator().generate(from: graph)
        XCTAssertTrue(code.contains("decorations: \"wave\""))
    }

    func testInteriorVertexIsRenderedAsFilledNode() {
    var graph = DiagramGraph()
    let v1 = graph.addVertex(at: Point(x: 0, y: 0))
    let v2 = graph.addVertex(at: Point(x: 1, y: 0))
    let v3 = graph.addVertex(at: Point(x: 2, y: 0))
    graph.addLine(startVertexID: v1.id, endVertexID: v2.id, type: .vector)
    graph.addLine(startVertexID: v2.id, endVertexID: v3.id, type: .vector)

    let code = TypstCodeGenerator().generate(from: graph)
    XCTAssertTrue(code.contains("node((1.0, 0.0), name: <v1>, radius: 2pt, fill: black)"))
    }

    func testIncomingVertexIsNamedWithIPrefix() {
        var graph = DiagramGraph()
        let v1 = graph.addVertex(at: Point(x: 0, y: 0), label: "q")
        let v2 = graph.addVertex(at: Point(x: 1, y: 0))
        graph.addLine(startVertexID: v1.id, endVertexID: v2.id, type: .fermion)

        let code = TypstCodeGenerator().generate(from: graph)
        XCTAssertTrue(code.contains("node((0.0, 0.0), $q$, name: <i1>)"))
    }

    func testScalarLineHasDashedStroke() {
        var graph = DiagramGraph()
        let v1 = graph.addVertex(at: Point(x: 0, y: 0))
        let v2 = graph.addVertex(at: Point(x: 1, y: 0))
        graph.addLine(startVertexID: v1.id, endVertexID: v2.id, type: .scalar)

        let code = TypstCodeGenerator().generate(from: graph)
        XCTAssertTrue(code.contains("stroke: (dash: \"dashed\")"))
    }
}

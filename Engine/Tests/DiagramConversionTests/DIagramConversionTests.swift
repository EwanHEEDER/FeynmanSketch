import XCTest
@testable import DiagramModel
@testable import DiagramConversion

final class DiagramConversionTests: XCTestCase {
    func testManualInspection() {
    var graph = DiagramGraph()
    let qIn = graph.addVertex(at: Point(x: 0, y: 0), label: "q")
    let qOut = graph.addVertex(at: Point(x: 4, y: 0), label: "q")
    let hOut = graph.addVertex(at: Point(x: 4, y: 2), label: "H")
    let v = graph.addVertex(at: Point(x: 2, y: 1))
    graph.addLine(startVertexID: qIn.id, endVertexID: v.id, type: .fermion)
    graph.addLine(startVertexID: v.id, endVertexID: qOut.id, type: .fermion)
    graph.addLine(startVertexID: v.id, endVertexID: hOut.id, type: .scalar)

    let code = TypstCodeGenerator().generate(from: graph)
    print(code)
    }
}

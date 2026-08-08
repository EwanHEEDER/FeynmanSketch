//
//  DiagramEditorViewModelTests.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 07/08/2026.
//

import Testing
@testable import FeynmanSketchMac
@testable import DiagramModel

@MainActor
struct DiagramEditorViewModelTests {
    
    @Test func testAddVertexAddsToGraph() {
        let viewModel = DiagramEditorViewModel()
        
        #expect(viewModel.graph.vertices.isEmpty)
        
        viewModel.addVertex(at: Point(x: 0, y: 0))
        #expect(viewModel.graph.vertices.count == 1)
    }
    
    @Test func testBeginOrCompleteLineOnFirstClickStoresPendingStart() {
        let viewModel = DiagramEditorViewModel()
        
        #expect(viewModel.graph.lines.isEmpty)
        
        let vertexA = Vertex(position: Point(x: 0, y: 0))
        viewModel.addVertex(at: vertexA.position)
        
        let createdLine = viewModel.beginOrCompleteLine(at: vertexA.position, type: .allCases.randomElement()!)
        
        #expect(viewModel.graph.lines.isEmpty)
        #expect(createdLine == nil)
    }
    
    @Test func testBeginOrCompleteLineOnSecondClickCreatesLine() {
        let viewModel = DiagramEditorViewModel()
        #expect(viewModel.graph.lines.isEmpty)
        
        let vertexA = Vertex(position: Point(x: 0, y: 0))
        viewModel.addVertex(at: vertexA.position)
        
        let vertexB = Vertex(position: Point(x: 1, y: 1))
        viewModel.addVertex(at: vertexB.position)
        
        let firstClick = viewModel.beginOrCompleteLine(at: vertexA.position, type: .allCases.randomElement()!)
        
        let secondClick = viewModel.beginOrCompleteLine(at: vertexB.position, type: .allCases.randomElement()!)
        
        #expect(secondClick != nil)
        #expect(viewModel.graph.lines.count == 1)
    }
    
    @Test func testBeginOrCompleteLineCanBeUsedTwiceInARow() {
        
        // Create first line, check, click on new vertex, check nothing is created, click on second vertex and check second line is created
        let viewModel = DiagramEditorViewModel()
        #expect(viewModel.graph.lines.isEmpty)
        
        let vertexA = Vertex(position: Point(x: 0, y: 0))
        viewModel.addVertex(at: vertexA.position)
        
        let vertexB = Vertex(position: Point(x: 1, y: 1))
        viewModel.addVertex(at: vertexB.position)
        
        let vertexC = Vertex(position: Point(x: 2, y: 2))
        viewModel.addVertex(at: vertexC.position)
        
        let firstClick = viewModel.beginOrCompleteLine(at: vertexA.position, type: .allCases.randomElement()!)
        
        let secondClick = viewModel.beginOrCompleteLine(at: vertexB.position, type: .allCases.randomElement()!)
        
        #expect(secondClick != nil)
        #expect(viewModel.graph.lines.count == 1)
        
        let thirdClick = viewModel.beginOrCompleteLine(at: vertexA.position, type: .allCases.randomElement()!)
        
        #expect(thirdClick == nil)
        #expect(viewModel.graph.lines.count == 1)
        
        let fourthClick = viewModel.beginOrCompleteLine(at: vertexC.position, type: .allCases.randomElement()!)
        
        #expect(fourthClick != nil)
        #expect(viewModel.graph.lines.count == 2)
    }
    
    @Test func testBeginOrCompleteLineCancelsOnSameVertexClickedTwice() {
        // Click twice on same vertex, check nothing is created, click a third time on same vertex, then click on second vertex and check a line is created
        let viewModel = DiagramEditorViewModel()
        #expect(viewModel.graph.lines.isEmpty)
        
        let vertexA = Vertex(position: Point(x: 0, y: 0))
        viewModel.addVertex(at: vertexA.position)
        
        let vertexB = Vertex(position: Point(x: 1, y: 1))
        viewModel.addVertex(at: vertexB.position)
        
        
        let firstClick = viewModel.beginOrCompleteLine(at: vertexA.position, type: .allCases.randomElement()!)
        
        let secondClick = viewModel.beginOrCompleteLine(at: vertexA.position, type: .allCases.randomElement()!)
        
        #expect(secondClick == nil)
        #expect(viewModel.graph.lines.count == 0)
        
        let thirdClick = viewModel.beginOrCompleteLine(at: vertexA.position, type: .allCases.randomElement()!)
        
        #expect(thirdClick == nil)
        #expect(viewModel.graph.lines.count == 0)
        
        let fourthClick = viewModel.beginOrCompleteLine(at: vertexB.position, type: .allCases.randomElement()!)
        
        #expect(fourthClick != nil)
        #expect(viewModel.graph.lines.count == 1)
    }
    
    @Test func testSelectElementUpdatesSelection() {
        let viewModel = DiagramEditorViewModel()
        
        #expect(viewModel.selection == nil)
        #expect(viewModel.graph.vertices.isEmpty)
        
        let vertexA = Vertex(position: Point(x: 0, y: 0))
        viewModel.addVertex(at: vertexA.position)
        
        //Try to select this vertex
        viewModel.selectElement(at: Point(x: 0, y: 0.1))
        
        guard case .vertex(let selectedVertex) = viewModel.selection else {
            Issue.record("No edge found")
            return
        }
        #expect(selectedVertex == viewModel.graph.vertices[0].id)
    }
    
    @Test func testDeleteSelectionRemovesVertex() {
        let viewModel = DiagramEditorViewModel()
        
        let vertexA = Vertex(position: Point(x: 0, y: 0))
        viewModel.addVertex(at: vertexA.position)
        
        viewModel.selectElement(at: Point(x: 0, y: 0.1))
        viewModel.deleteSelection()
        
        #expect(viewModel.graph.vertices.isEmpty)
    }
    
    @Test func testDeleteSelectionRemovesLine() {
        let viewModel = DiagramEditorViewModel()
        #expect(viewModel.graph.lines.isEmpty)
        
        viewModel.addVertex(at: Point(x: 0, y: 0))
        viewModel.addVertex(at:Point(x: 20, y: 0))
        
        let vertexA = viewModel.graph.vertices[0]
        let vertexB = viewModel.graph.vertices[1]
        
        viewModel.graph.addLine(startVertexID: vertexA.id, endVertexID: vertexB.id, type: .fermion)
        #expect(viewModel.graph.lines.count == 1)
        
        viewModel.selectElement(at: Point(x: 10, y: 0))
        viewModel.deleteSelection()
        #expect(viewModel.graph.lines.isEmpty)
    }
    
    @Test func testDeleteSelectionDoesNothingWhenNoSelection() {
        let viewModel = DiagramEditorViewModel()
        #expect(viewModel.graph.lines.isEmpty)
        
        viewModel.addVertex(at: Point(x: 0, y: 0))
        viewModel.addVertex(at:Point(x: 20, y: 0))
        
        #expect(viewModel.graph.vertices.count == 2)
        
        let vertexA = viewModel.graph.vertices[0]
        let vertexB = viewModel.graph.vertices[1]
        
        viewModel.graph.addLine(startVertexID: vertexA.id, endVertexID: vertexB.id, type: .fermion)
        #expect(viewModel.graph.lines.count == 1)
        
        viewModel.deleteSelection()
        
        #expect(viewModel.selection == nil)
        #expect(viewModel.graph.vertices.count == 2)
        #expect(viewModel.graph.lines.count == 1)
    }
}

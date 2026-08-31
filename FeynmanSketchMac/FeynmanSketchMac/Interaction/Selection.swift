//
//  Selection.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 06/08/2026.
//
import DiagramModel

/// Currently-selected item on the canvas, when `.select` tool is active.
///
/// This enum is completely distinct of the ``DiagramModel`` types, and only refers the object the user is pointing at. Some actions such as deletion or label editing can only be performed on a non-nil Selection.
enum Selection: Equatable {
    /// Selected vertex, identified by its ID in the current ``DiagramGraph``.
    case vertex(Vertex.ID)
    /// Selected line, identified by its ID in the current ``DiagramGraph``.
    case line(PropagatorLine.ID)
}

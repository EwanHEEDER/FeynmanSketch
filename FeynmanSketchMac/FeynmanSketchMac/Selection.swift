//
//  Selection.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 06/08/2026.
//
import DiagramModel

enum Selection: Equatable {
    case vertex(Vertex.ID)
    case line(PropagatorLine.ID)
}

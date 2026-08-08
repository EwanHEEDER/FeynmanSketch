//
//  ToolboxViewModel.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 06/08/2026.
//

import DiagramModel
import Combine

@MainActor
final class ToolboxViewModel: ObservableObject {
    enum Tool: Equatable {
        case vertex
        case line(LineType)
        case select
    }
    
    @Published var activeTool: Tool = .select
}

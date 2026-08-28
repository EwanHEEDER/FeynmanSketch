//
//  ToolboxViewModel.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 06/08/2026.
//

import DiagramModel
import Combine

/// Stores the currently active drawing tool, and is shared between the toolbar and the canvas.
@MainActor
final class ToolboxViewModel: ObservableObject {
    /// Represents a tool the user can select from the toolbar. It determines the effect of a touch or a drag on the canvas.
    enum Tool: Equatable {
        /// Tapping the canvas places a new vertex at the tapped position.
        case vertex
        /// Tapping two vertices in a row adds  a line of this ``LineType`` between them.
        case line(LineType)
        /// Tapping a vertex or a line makes it the current selection and enables to delete it or custom its label.
        case select
        /// Display a draggable control point on every line currently on the canvas, allowing to adjust their curvature.
        case curvature
    }
    /// The currently active tool, set by default to `.select`.
    @Published var activeTool: Tool = .select
}

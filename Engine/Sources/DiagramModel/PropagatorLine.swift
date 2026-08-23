import Foundation
/// A propagator line conecting two vertices
///
/// The direction from `startVertexID`` to ``endVertexID`` is meaningful, in particular for a `.fermion` line, in which it determines the direction of the mid-line arrow. It has no visual effect on other line types.
public struct PropagatorLine: Codable, Equatable, Identifiable {
    /// Stable identifier, generated automatically unless explicitely provided
    public let id: UUID
    /// The vertex this line starts from
    public var startVertexID: Vertex.ID
    /// The vertex this line end to
    public var endVertexID: Vertex.ID
    /// The line' s drawing style to apply
    public var type: LineType
    /// Optionnal label, e.g to differentiate particles that would be drawn with same line style. This argument is interpreted in math mode in generated code, so special characters are available ("\gamma" would be displayed as the correct greek letter)
    public var label: String?
    /// Line's curvature, in degrees
    ///
    /// The whole curvature logic follows Typst fletcher's one: This angle is the one between arc chord and tangeant to the curve at its starting point: 0° is as flat line and 90° is a semi-circle
    public var curvature: Double

    public init(
        id: UUID = UUID(),
        startVertexID: Vertex.ID,
        endVertexID: Vertex.ID,
        type: LineType,
        label: String? = nil,
        curvature: Double = 0.0
    ) {
        self.id = id
        self.startVertexID = startVertexID
        self.endVertexID = endVertexID
        self.type = type
        self.label = label
        self.curvature = curvature
    }

}

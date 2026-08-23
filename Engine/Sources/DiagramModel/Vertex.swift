import Foundation

/// A point in the diagram, either an interaction vertex or the endpoint of an external line. This role is not stored is the structure itself, but derives from the number of lines it is connected to. See ``DiagramGraph/role(of:)``
public struct Vertex: Codable, Identifiable, Equatable {
    /// Stable identifier, generated automatically unless explicitely provided
    public let id: UUID
    /// The vertex's position, in the diagram's internal coordinate system
    public var position: Point
    /// Optional label, typically used to name the particle at an external vertex or left `nil` for internal vertices
    public var label: String?

    public init(
        id: UUID = UUID(),
        position: Point,
        label: String? = nil
    ) {
        self.id = id
        self.position = position
        self.label = label
    }
}

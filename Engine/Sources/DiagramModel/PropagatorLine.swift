import Foundation

public struct PropagatorLine: Codable, Equatable, Identifiable {
    public let id: UUID
    public var startVertexID: Vertex.ID
    public var endVertexID: Vertex.ID
    public var type: LineType
    public var label: String?
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

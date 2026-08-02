import Foundation

public struct Vertex: Codable, Identifiable, Equatable {
    public let id: UUID
    public var position: Point
    public var label: String?
    public var isInternal: Bool

    public init(
        id: UUID = UUID(),
        position: Point,
        label: String? = nil,
        isInternal: Bool = true
    ) {
        self.id = id
        self.position = position
        self.label = label
        self.isInternal = isInternal
    }
}

public struct Point: Codable, Equatable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public func distance(to other: Point) -> Double {
        let distX = other.x - self.x
        let distY = other.y - self.y
        return (distX * distX + distY * distY).squareRoot()
    }
}

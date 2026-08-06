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

    func distance(toSegmentFrom a: Point, to b: Point) -> Double {
        let dx = b.x - a.x
        let dy = b.y - a.y

        let lengthSquared = dx * dx + dy * dy

        // handle nul segment

        guard lengthSquared > 0 else {
            return distance(to: a)
        }

        // Project p on (a, b), express as a fraction t along the segment

        let t = ((x - a.x) * dx + (y - a.y) * dy) / lengthSquared
        let clampedT = max(0, min(1, t))

        let closestPoint = Point(x: a.x + clampedT * dx, y: a.y + clampedT * dy)

        return distance(to: closestPoint)
    }
}

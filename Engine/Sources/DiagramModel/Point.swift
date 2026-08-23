/// A point represents an abstract position inside of the diagram, in the internal coordinate system.
///
/// This position is is converted in pixel / grid units by the UI itself, eventually being grid-snapped

public struct Point: Codable, Equatable {
    /// Horizontal coordinate
    public var x: Double
    /// Vertical coordinate
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    /// Euclidian distance between this point and another
    /// - Parameter other: the point to measure distance to
    /// - Returns: non-negative distance, in diagram units
    public func distance(to other: Point) -> Double {
        let distX = other.x - self.x
        let distY = other.y - self.y
        return (distX * distX + distY * distY).squareRoot()
    }

    /// Perpendicular distance between this point and the segment going from a to b.
    /// This clamps the projection to the segment, if projection on (a,b) axis is outside [a,b] segment, distance is measured to the closest endpoint.
    /// - Parameters:
    ///     - a: Segment's starting point
    ///     - b: Segment's ending point
    /// - Returns: Non-negative distance. If 'a' and 'b' coincide, this function is equivalent to 'distance(to: a)'
    public func distance(toSegmentFrom a: Point, to b: Point) -> Double {
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

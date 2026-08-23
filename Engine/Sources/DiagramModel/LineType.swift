/// The four propagator line styles supported by the diagram model
///
/// Each one is a drawing convention that can be used for different particles, the distinction being left to the line label if needed

public enum LineType: Codable, Equatable, CaseIterable {
    /// Straight line with mid-line arrow towards end point
    case fermion
    /// Coiled line
    case gluon
    /// Wavy line
    case vector
    /// Dashed line
    case scalar

    /// Short, readable name for each line type, to be used in GUI (e.g as help for the buttons)
    public var displayName: String {
        switch self {
        case .fermion:
            return "Fermion"
        case .gluon:
            return "Gluon"
        case .vector:
            return "Vector boson"
        case .scalar:
            return "Scalar boson"
        }
    }
}

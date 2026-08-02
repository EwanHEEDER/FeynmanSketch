public enum LineType: Codable, Equatable, CaseIterable {
    case fermion, gluon, vector, scalar

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

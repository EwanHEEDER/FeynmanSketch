import DiagramModel

enum FletcherSyntax {
    static func markArgument(for type: LineType) -> String {
        switch type {
            case .fermion:
                return "-|>-"
            case .gluon, .vector, .scalar:
                return "-"
        }
    }

    static func decorations(for type: LineType) -> String? {
        switch type {
            case .fermion, .scalar:
                return nil
            case .gluon:
                return "coil"
            case .vector:
                return "wave"
        }
    }

    static func extraEdgeArguments(for type: LineType) -> [String] {
        switch type {
            case .scalar:
                return ["stroke: (dash: \"dashed\")"]
            case .gluon, .vector, .fermion:
                return []
        }
    }
}
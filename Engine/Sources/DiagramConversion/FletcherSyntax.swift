import DiagramModel
/// Correspondance  between ``LineType`` and fletcher's syntaxe for edges (marks and decorations). This mapping is specific to Typst/fletcher and is intentionnaly kept out of ``LineType`` to make easier the future addition other languages.
enum FletcherSyntax {
    /// The positionnal "mark" argument for `edge(...)`, e.g a dmi-line arrow for fermion lines.
    /// - Parameter type: The line type to determine the fletcher mark for.
    /// - Returns: A fletcher mark string, such as `"-|>-"` or  `"-"`.
    static func markArgument(for type: LineType) -> String {
        switch type {
            case .fermion:
                return "-|>-"
            case .gluon, .vector, .scalar:
                return "-"
        }
    }

    /// The `decorations:` argument for `edge(...)` if this line type requieres one.
    /// - Parameter type: The line type to determine decoration for.
    /// - Returns: `"wave"` for vector bosons, `"coil"` for gluons or `nil` for other types for which no decoration is needed.
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

    /// Any additional raw Typst arguments this line type requieres beyond the mark and decoration (essentialy producing a dashed line for `.scalar` lines).
    /// - Parameter type: The line type to determine extra arguments for.
    /// - Returns: An array of raw Typst arguments strings.
    static func extraEdgeArguments(for type: LineType) -> [String] {
        switch type {
            case .scalar:
                return ["stroke: (dash: \"dashed\")"]
            case .gluon, .vector, .fermion:
                return []
        }
    }
}

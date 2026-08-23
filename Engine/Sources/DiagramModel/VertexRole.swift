/// Vertex role within a diagram, entierely determined by its topology: how many lines are connected to it, and in which direction.
///
/// This role is never attached to ``Vertex`` itself, it is always computed on demand by calling ``DiagramGraph/role(of:)``, so that it does not need to be checked for every vertex each time a line is added/removed.
public enum VertexRole: Equatable {
    /// An interaction vertex: two or more lines connected to it.
    case interior
    /// A vertex from which an external leg starts: Exactly one line connected to it, for which it corresponds to `startVertexID`.
    case incoming
    /// A vertex to which and external leg ends: Exactly one line connected to it, for which it corresponds to `endVertexID`.
    case outgoing
    /// A vertex without any connected line. Such vertex has no standard physical meaning but still represents a valid state of a ``Vertex`` object.
    case isolated
}

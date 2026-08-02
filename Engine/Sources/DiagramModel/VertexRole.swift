public enum VertexRole: Equatable {
    case interior // 2 lines or more
    case incoming // 1 line, for which the vertex is the start
    case outgoing // 1 line, for which the vertex is the end
    case isolated // 0 lines
}
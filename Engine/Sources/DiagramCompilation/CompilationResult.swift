import Foundation

public enum CompilationResult: Equatable, Sendable {
    case success(svgData: Data)
    case failure(diagnostics: String)
}
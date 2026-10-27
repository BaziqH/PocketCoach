//
//  PCHexagonShape.swift
//  PocketCoach
//

/// Geometric hexagonal shape embodying the brand geometry of performance machinery.
struct PCHexagonShape: Shape {
    /// Generates a sharp six-sided polygon path within the specified bounding rectangle.
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        guard width > 0, height > 0 else { return path }

        let sideIndent = width * 0.25

        path.move(to: CGPoint(x: sideIndent, y: 0))
        path.addLine(to: CGPoint(x: width - sideIndent, y: 0))
        path.addLine(to: CGPoint(x: width, y: height * 0.5))
        path.addLine(to: CGPoint(x: width - sideIndent, y: height))
        path.addLine(to: CGPoint(x: sideIndent, y: height))
        path.addLine(to: CGPoint(x: 0, y: height * 0.5))
        path.closeSubpath()

        return path
    }
}

import SwiftUI

/// Clippy-style speech bubble with a tail on the bottom edge.
struct BubbleShape: Shape {
    static let tailHeight: CGFloat = 14
    static let fill = Color(red: 1.0, green: 0.99, blue: 0.80)

    /// Where the tail sits along the bottom edge, 0 = left, 1 = right.
    var tailX: CGFloat = 0.6

    func path(in r: CGRect) -> Path {
        let tailH = BubbleShape.tailHeight
        let rad = min(16, (r.height - tailH) / 2)
        let body = CGRect(x: r.minX, y: r.minY, width: r.width, height: r.height - tailH)
        let tx = min(max(r.minX + r.width * tailX, body.minX + rad + 12), body.maxX - rad - 12)

        var p = Path()
        p.move(to: CGPoint(x: body.minX + rad, y: body.minY))
        p.addLine(to: CGPoint(x: body.maxX - rad, y: body.minY))
        p.addArc(tangent1End: CGPoint(x: body.maxX, y: body.minY),
                 tangent2End: CGPoint(x: body.maxX, y: body.minY + rad), radius: rad)
        p.addLine(to: CGPoint(x: body.maxX, y: body.maxY - rad))
        p.addArc(tangent1End: CGPoint(x: body.maxX, y: body.maxY),
                 tangent2End: CGPoint(x: body.maxX - rad, y: body.maxY), radius: rad)
        p.addLine(to: CGPoint(x: tx + 10, y: body.maxY))
        p.addLine(to: CGPoint(x: tx - 2, y: r.maxY))
        p.addLine(to: CGPoint(x: tx - 10, y: body.maxY))
        p.addLine(to: CGPoint(x: body.minX + rad, y: body.maxY))
        p.addArc(tangent1End: CGPoint(x: body.minX, y: body.maxY),
                 tangent2End: CGPoint(x: body.minX, y: body.maxY - rad), radius: rad)
        p.addLine(to: CGPoint(x: body.minX, y: body.minY + rad))
        p.addArc(tangent1End: CGPoint(x: body.minX, y: body.minY),
                 tangent2End: CGPoint(x: body.minX + rad, y: body.minY), radius: rad)
        p.closeSubpath()
        return p
    }
}

/// Background used by the app and the widget.
let skyGradient = LinearGradient(
    colors: [Color(red: 0.62, green: 0.84, blue: 1.0), Color(red: 1.0, green: 0.80, blue: 0.90)],
    startPoint: .top, endPoint: .bottom)

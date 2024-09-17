import SwiftUI

func extractCopyrightInfo(from copyright: String) -> String {
    let components = copyright.components(separatedBy: " (")
    if components.count > 1 {
        let copyrightInfo = components[1].replacingOccurrences(of: ")", with: "")
        if copyrightInfo.hasPrefix("©") {
            return copyrightInfo
        } else {
            return "© " + copyrightInfo
        }
    }
    return copyright
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
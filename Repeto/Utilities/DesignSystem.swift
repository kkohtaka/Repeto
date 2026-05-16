//
//  DesignSystem.swift
//  Repeto
//

import SwiftUI

enum DesignSystem {
    enum Spacing: CGFloat {
        case xs = 4
        case sm = 8
        case md = 16
        case lg = 20
        case xl = 32
    }

    enum Radius: CGFloat {
        case sm = 8
        case md = 12
        case lg = 16
    }

    enum IconSize: CGFloat {
        case sm = 20
        case md = 44
        case lg = 80
    }

    enum StatusColor {
        case overdue, today, upcoming

        var color: Color {
            switch self {
            case .overdue: .red
            case .today: .orange
            case .upcoming: .primary
            }
        }
    }

    static func spacing(_ token: Spacing) -> CGFloat { token.rawValue }
    static func radius(_ token: Radius) -> CGFloat { token.rawValue }
    static func iconSize(_ token: IconSize) -> CGFloat { token.rawValue }
    static func statusColor(_ token: StatusColor) -> Color { token.color }
}

extension ShapeStyle where Self == Color {
    static var accent: Color { .blue }
    static var destructive: Color { .red }
}

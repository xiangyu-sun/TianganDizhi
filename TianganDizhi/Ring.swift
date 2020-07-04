//
//  Ring.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/07/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
import Combine

struct WedgeShape: Shape {
    var wedge: Ring.Wedge

    init(_ wedge: Ring.Wedge) { self.wedge = wedge }
    
    func path(in rect: CGRect) -> Path {
        let points = WedgeGeometry(wedge, in: rect)
        
        var path = Path()
        
        path.addArc(center: points.center, radius: points.innerRadius,
                    startAngle: .radians(wedge.start), endAngle: .radians(wedge.end),
                    clockwise: false)
        
        path.addLine(to: points[.bottomTrailing])
        
        path.addArc(center: points.center, radius: points.outerRadius,
                    startAngle: .radians(wedge.end), endAngle: .radians(wedge.start),
                    clockwise: true)
        
        path.closeSubpath()
        
        return path
    }
}


class Ring: ObservableObject {

    static var model: Ring{
        let ring = Ring()
        for _ in 0 ..< 12 {
            ring.addWedge(.fixedWidth)
        }
        return ring
    }
    

    struct Wedge: Equatable {
        
        /// The wedge's width, as an angle in radians.
        var width: Double
        /// The wedge's cross-axis depth, in range [0,1].
        var depth: Double
        /// The ring's hue.
        var hue: Double
        
        
        /// The wedge's start location, as an angle in radians.
        fileprivate(set) var start = 0.0
        /// The wedge's end location, as an angle in radians.
        fileprivate(set) var end = 0.0

        static var random: Wedge {
            return Wedge(
                width: .random(in: 0.5 ... 1),
                depth: .random(in: 0.2 ... 1),
                hue: .random(in: 0 ... 1))
        }
        
        static var fixedWidth: Wedge {
                return Wedge(
                    width: 1,
                    depth: 1,
                    hue: .random(in: 0 ... 1))
            }
    }

    /// The collection of wedges, tracked by their id.
    var wedges: [Int: Wedge] {
        get {
            if _wedgesNeedUpdate {
                /// Recalculate locations, to pack within circle.
                let total = wedgeIDs.reduce(0.0) { $0 + _wedges[$1]!.width }
                let scale = (.pi * 2) / max(.pi * 2, total)
                var location = 0.0
                for id in wedgeIDs {
                    var wedge = _wedges[id]!
                    wedge.start = location * scale
                    location += wedge.width
                    wedge.end = location * scale
                    _wedges[id] = wedge
                }
                _wedgesNeedUpdate = false
            }
            return _wedges
        }
        set {
            objectWillChange.send()
            _wedges = newValue
            _wedgesNeedUpdate = true
        }
    }

    private var _wedges = [Int: Wedge]()
    private var _wedgesNeedUpdate = false

    /// The display order of the wedges.
    private(set) var wedgeIDs = [Int]() {
        willSet {
            objectWillChange.send()
        }
    }

    /// The next id to allocate.
    private var nextID = 0

    /// Trivial publisher for our changes.
    let objectWillChange = PassthroughSubject<Void, Never>()

    /// Adds a new wedge description to `array`.
    func addWedge(_ value: Wedge) {
        let id = nextID
        nextID += 1
        wedges[id] = value
        wedgeIDs.append(id)
    }

    /// Removes the wedge with `id`.
    func removeWedge(id: Int) {
        if let indexToRemove = wedgeIDs.firstIndex(where: { $0 == id }) {
            wedgeIDs.remove(at: indexToRemove)
            wedges.removeValue(forKey: id)
        }
    }

    /// Clear all data.
    func reset() {
        if !wedgeIDs.isEmpty {
            wedgeIDs = []
            wedges = [:]
        }
    }
}

/// Helper type for creating view-space points within a wedge.
private struct WedgeGeometry {
    var wedge: Ring.Wedge
    var center: CGPoint
    var innerRadius: CGFloat
    var outerRadius: CGFloat
    
    init(_ wedge: Ring.Wedge, in rect: CGRect) {
        self.wedge = wedge
        center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.5
        innerRadius = radius / 4
        outerRadius = innerRadius +
            (radius - innerRadius) * CGFloat(wedge.depth)
    }
    
    /// Returns the view location of the point in the wedge at unit-
    /// space location `unitPoint`, where the X axis of `p` moves around the
    /// wedge arc and the Y axis moves out from the inner to outer
    /// radius.
    subscript(unitPoint: UnitPoint) -> CGPoint {
        let radius = lerp(innerRadius, outerRadius, by: unitPoint.y)
        let angle = lerp(wedge.start, wedge.end, by: Double(unitPoint.x))
        
        return CGPoint(x: center.x + CGFloat(cos(angle)) * radius,
                       y: center.y + CGFloat(sin(angle)) * radius)
    }

}



/// Colors derived from the wedge hue for drawing.
extension Ring.Wedge {
    var startColor: Color {
        return Color(hue: hue, saturation: 0.4, brightness: 0.8)
    }
    
    var endColor: Color {
        return Color(hue: hue, saturation: 0.7, brightness: 0.9)
    }
    
    var backgroundColor: Color {
        Color(hue: hue, saturation: 0.5, brightness: 0.8, opacity: 0.1)
    }
    
    var foregroundGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [startColor, endColor]),
            center: .center,
            startAngle: .radians(start),
            endAngle: .radians(end)
        )
    }
}


/// Linearly interpolate from `from` to `to` by the fraction `amount`.
private func lerp<T: BinaryFloatingPoint>(_ fromValue: T, _ toValue: T, by amount: T) -> T {
    return fromValue + (toValue - fromValue) * amount
}

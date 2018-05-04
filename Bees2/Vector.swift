//
//  Vector.swift
//  Bees2
//
//  Created by Thomas Blench on 09/04/2018.
//  Copyright © 2018 Thomas Blench. All rights reserved.
//

import Foundation

public class Vector {
    
    public init() {
        self.x = 0
        self.y = 0
    }
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    public func mag() -> Float {
        return sqrt(x*x+y*y)
    }
    
    public static func *(lhs: Vector, rhs: Float) -> Vector {
        return Vector(x: lhs.x*rhs, y: lhs.y*rhs)
    }

    public static func /(lhs: Vector, rhs: Float) -> Vector {
        return Vector(x: lhs.x/rhs, y: lhs.y/rhs)
    }
    
    public static func +(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x+rhs.x, y: lhs.y+rhs.y)
    }

    public static func -(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x-rhs.x, y: lhs.y-rhs.y)
    }

    
    public var x: Float
    public var y: Float
}

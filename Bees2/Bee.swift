//
//  Bee.swift
//  Bees2
//
//  Created by Thomas Blench on 09/04/2018.
//  Copyright © 2018 Thomas Blench. All rights reserved.
//

import Foundation

public class Bee {
    
    public init() {
        self.direction = Vector()
        self.position = Vector()
    }
    
    public init(x: Double, y:Double) {
        self.position = Vector(x: x, y: y)
        self.direction = Vector()
    }
    
    public func step() {
        self.position = self.position + self.direction
    }
    
    public var position: Vector
    public var direction: Vector
    
}

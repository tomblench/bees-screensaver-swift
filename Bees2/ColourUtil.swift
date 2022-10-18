//
//  ColourUtil.swift
//  Bees2
//
//  Created by Thomas Blench on 17/10/2022.
//  Copyright © 2022 Thomas Blench. All rights reserved.
//

import Foundation

// adapted from https://stackoverflow.com/questions/3018313/algorithm-to-convert-rgb-to-hsv-and-hsv-to-rgb-in-range-0-255-for-both/6930407#6930407
// inputs and outputs all [0..1]
func hsvToRgb(h: Float, s: Float, v: Float) -> (Float, Float, Float)
{
    let hh = h * 6.0
    let i = Int(hh)
    let ff = hh - Float(i)
    let p = v * (1.0 - s)
    let q = v * (1.0 - (s * ff))
    let t = v * (1.0 - (s * (1.0 - ff)))
    var r = Float()
    var g = Float()
    var b = Float()
    switch(i) {
        case 0:
            r = v;
            g = t;
            b = p;
            break;
        case 1:
            r = q;
            g = v;
            b = p;
            break;
        case 2:
            r = p;
            g = v;
            b = t;
            break;
        case 3:
            r = p;
            g = q;
            b = v;
            break;
        case 4:
            r = t;
            g = p;
            b = v;
            break;
        default:
            r = v;
            g = p;
            b = q;
            break;
        }
    return (r, g, b)
}

//
//  BeesSwiftView.swift
//  Bees2
//
//  Created by Thomas Blench on 09/04/2018.
//  Copyright © 2018 Thomas Blench. All rights reserved.
//

import Foundation
import ScreenSaver

class SwiftSS: ScreenSaverView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        
        NSColor.red.setFill()
        NSRectFill(self.bounds)
        NSColor.black.set()
        
        
        let hello:NSString = "hello SWIFT screen saver plugin"
        hello.draw(at: (NSPoint(x: 100.0, y: 200.0)), withAttributes: nil)
    }
    
    
}

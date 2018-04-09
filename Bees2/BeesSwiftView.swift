//
//  BeesSwiftView.swift
//  Bees2
//
//  Created by Thomas Blench on 09/04/2018.
//  Copyright © 2018 Thomas Blench. All rights reserved.
//

import Foundation
import ScreenSaver

public class BeesSwiftView: ScreenSaverView {
    
    let queen = Bee()
    
    override public init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        queen.position.x = self.bounds.width.native/2.0;
        queen.position.y = self.bounds.height.native/2.0;
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func animateOneFrame() {
        queen.direction.x = drand48()*10.0-5.0;
        queen.direction.y = drand48()*10.0-5.0;
        queen.step()
        NSColor.white.setFill()
        NSRectFill(self.bounds)
        NSColor.blue.set()
        NSRectFill(NSRect(x: queen.position.x, y: queen.position.y, width: 5.0, height: 5.0))
    }

    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    
}

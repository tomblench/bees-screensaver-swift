//
//  BeesSwiftView.swift
//  Bees2
//
//  Created by Thomas Blench on 09/04/2018.
//  Copyright © 2018, 2022 Thomas Blench. All rights reserved.
//

import Foundation
import ScreenSaver

public class BeesSwiftView: ScreenSaverView {
    
    // beezzz
    var queens = Array<Bee>()
    var swarm = Array<Bee>()
    
    // used for fading/persistence
    var image: CGImage?
    
    // how many frames before a drone in respawned - also the length of the colour cycle in rainbow mode
    static let ageLimit = 2000
    // how many frames to fade in new drones
    static let fadeIn = 300.0
    
    // for displaying preferences sheet and getting preferences values
    let prefs = Prefs()
    
    private func randomPoint(x: Float, y: Float) -> Vector {
        return Vector(x: Float(drand48()) * x, y: Float(drand48()) * y)
    }

    private func randomPoint(range: Float, offset: Float) -> Vector {
        return Vector(x: Float(drand48()) * range - offset, y: Float(drand48()) * range - offset)
    }

    private func randomCircularPoint(x: Float, y: Float) -> Vector {
        // circle radius min(x,y), centred at origin
        let circ = Vector(r: Float(min(x/2, y/2)), θ: Float(drand48())*Float.pi*2)
        // move into middle
        return circ + Vector(x: x/2, y: y/2)
    }
    
    private func seedQueens(n: Int) {
        // seed queens in centre
        for _ in 1...(prefs.queenNumber) {
            queens.append(Bee(v: Vector(x: Float(self.bounds.width.native)/2, y: Float(self.bounds.height.native)/2)))
        }
    }

    private func seedDrones(n: Int) {
        // seed drones in random positions
        for _ in 1...(prefs.swarmNumber)  {
            swarm.append(Bee(v: randomCircularPoint(x: Float(self.bounds.width.native), y: Float(self.bounds.height.native))))
        }
    }
    
    override public init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        prefs.syncPrefsToFields()
        // use our bundle id to register defaults
        NSLog("Bundle name %@", Bundle.init(for: BeesSwiftView.self).bundleIdentifier!)
        initialiseBees()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func reinitialiseBees() {
        queens.removeAll()
        swarm.removeAll()
        initialiseBees()
    }
    
    public func initialiseBees() {
        seedQueens(n: prefs.queenNumber)
        seedDrones(n: prefs.swarmNumber)
    }
    
    public override func animateOneFrame() {
        self.needsDisplay = true
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let buffer = CGLayer(NSGraphicsContext.current!.cgContext, size: frame.size, auxiliaryInfo: nil)
        let context = buffer?.context
        
        // first frame only
        if (self.image != nil) {
            buffer?.context!.draw(image!, in: self.bounds)
        }
        
        // draw black rectangle with `fade` alpha onto context - the lower `fade` is, the more persistence there is
        context?.setFillColor(red: 0, green: 0, blue: 0, alpha: CGFloat(prefs.fade))
        context?.fill(self.bounds)
        
        // so bees don't obscure each other, draw in "lighten" blend mode
        context?.setBlendMode(CGBlendMode.lighten)
        // and give them some chunkiness
        context?.setLineWidth(5.0)
        context?.setLineCap(CGLineCap.butt)

        // animate swarm
        for d in swarm {
            // set vector towards queen
            // find closest queen, its difference vector, and magnitude
            let diff = queens.map { (q) -> (Bee, Vector, Float) in
                let diff = q.position - d.position
                return (q, diff, diff.mag²())
            }.min { (arg0, arg1) -> Bool in
                return arg0.2 < arg1.2
            }
            
            // re-spawn drone if it's too close to queen OR too old
            if (d.age > BeesSwiftView.ageLimit || (diff?.2)! < prefs.respawnRadius²) {
                d.position = randomCircularPoint(x: Float(self.bounds.width.native), y: Float(self.bounds.height.native))
                d.direction.x = 0
                d.direction.y = 0
                d.age = 0
                continue
            }
            // change direction vector to seek queen
            d.direction = d.direction + (diff?.1)! * prefs.swarmAcceleration
            
            // limit speed of drones
            let scale = d.direction.mag() / prefs.swarmSpeed
            if (scale > 1.0) {
                d.direction = d.direction / scale
            }
            
            // fade in by age
            // either use "rainbow" colour from HSV or colour from picker
            if (prefs.swarmRainbow) {
                let col = hsvToRgb(h: Float(d.age) / Float(BeesSwiftView.ageLimit), s: 1.0, v: 1.0)
                context?.setStrokeColor(red: CGFloat(col.0), green: CGFloat(col.1), blue: CGFloat(col.2), alpha: CGFloat(min(Double(d.age) / BeesSwiftView.fadeIn, 1.0)))
            } else {
                context?.setStrokeColor(red: CGFloat(prefs.swarmColour[0]), green: CGFloat(prefs.swarmColour[1]), blue: CGFloat(prefs.swarmColour[2]), alpha: CGFloat(min(Double(d.age) / BeesSwiftView.fadeIn, 1.0)))
            }
            
            // draw drone
            context?.strokeLineSegments(between: [CGPoint(x: Double(d.position.x), y: Double(d.position.y)),
                                                  CGPoint(x: Double(d.position.x + d.direction.x), y: Double(d.position.y+d.direction.y))])
            d.step()
        }
        
        // animate queen
        context?.setBlendMode(CGBlendMode.normal)
        for q in queens {
            q.direction = randomPoint(range: prefs.queenSpeed, offset: prefs.queenSpeed / 2.0)
            // wrap
            if (q.position.x < 0) {
                q.position.x = Float(self.bounds.width)
            }
            else if (q.position.x > Float(self.bounds.width)) {
                q.position.x = 0
            }
            if (q.position.y < 0) {
                q.position.y = Float(self.bounds.height)
            }
            else if (q.position.y > Float(self.bounds.height)) {
                q.position.y = 0
            }
            if (prefs.queenVisible) {
                // draw queen
                context?.setStrokeColor(red: CGFloat(prefs.queenColour[0]), green: CGFloat(prefs.queenColour[1]), blue: CGFloat(prefs.queenColour[2]), alpha: 1.0)
                context?.strokeLineSegments(between: [CGPoint(x: Double(q.position.x), y: Double(q.position.y)),
                                                      CGPoint(x: Double(q.position.x + q.direction.x), y: Double(q.position.y+q.direction.y))])
            }
            q.step()
        }
        
        // draw buffer directly into screen context
        NSGraphicsContext.current?.cgContext.draw(buffer!, at: CGPoint())
        // take "snapshot" of layer for drawing at next frame for persistence
        self.image = (context!.makeImage())!
    }
    
    // config sheet - most of this is handed over to Prefs
    public override var hasConfigureSheet: Bool {
        get {
            NSLog("**** hasConfigureSheet")
            return true
        }
    }
    
    public override var configureSheet:  NSWindow? {
        get {
            NSLog("**** configureSheet")
            var objects = Optional.some(NSArray())
            Bundle.init(for: BeesSwiftView.self).loadNibNamed(NSNib.Name("ConfigureSheet"), owner: self.prefs, topLevelObjects: &objects)
            prefs.configureSheet(view: self)
            return prefs.sheet
        }
    }
}

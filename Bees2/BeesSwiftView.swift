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
    
    // beezzz
    var queens = Array<Bee>()
    var swarm = Array<Bee>()
    
    // used for fading/persistence
    var image: CGImage?
    
    // how many frames before a drone in respawned
    static let ageLimit = 300
    // how many frames to fade in new drones (???)
    static let fadeIn = 300.0
    
    // for displaying preferences sheet and getting preferences values
    let prefs = Prefs()
    
    private func randomPoint(x: Float, y: Float) -> Vector {
        return Vector(x: Float(drand48())*x, y: Float(drand48())*y)
    }
    
    private func randomCircularPoint(x: Float, y: Float) -> Vector {
        // circle radius min(x,y), centred at origin
        let circ = Vector(r: Float(min(x/2, y/2)), θ: Float(drand48())*Float.pi*2)
        // move into middle
        return circ + Vector(x: x/2, y: y/2)
    }
    
    override public init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        // use our bundle id to register defaults
        NSLog("Bundle name %@", Bundle.init(for: BeesSwiftView.self).bundleIdentifier!)
        
        // seed queens in centre
        for _ in 1...(prefs.saverDefaults.integer(forKey: Prefs.queenNumberPrefsKey)) {
            queens.append(Bee(v: Vector(x: Float(self.bounds.width.native)/2, y: Float(self.bounds.height.native)/2)))
        }
        // seed drones in random positions
        for _ in 1...(prefs.saverDefaults.integer(forKey: Prefs.swarmNumberPrefsKey))  {
            swarm.append(Bee(v: randomCircularPoint(x: Float(self.bounds.width.native), y: Float(self.bounds.height.native))))
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func animateOneFrame() {
        self.needsDisplay = true
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let buffer = CGLayer(NSGraphicsContext.current!.cgContext, size: frame.size, auxiliaryInfo: nil)
        
        let context = buffer?.context
        
        if (self.image != nil) {
            buffer?.context!.draw(image!, in: self.bounds)
        }
        
        // animate swarm
        let colour = prefs.saverDefaults.array(forKey: Prefs.swarmColourPrefsKey) as! [Double]
        let queenColour = prefs.saverDefaults.array(forKey: Prefs.queenColourPrefsKey) as! [Double]
        let respawnRadius = (prefs.saverDefaults.float(forKey: Prefs.swarmRespawnRadiusPrefsKey))
        let swarmAcceleration = (prefs.saverDefaults.float(forKey: Prefs.swarmAccelerationPrefsKey))
        let queenSpeed = (prefs.saverDefaults.float(forKey: Prefs.queenSpeedPrefsKey))
        let swarmSpeed = (prefs.saverDefaults.float(forKey: Prefs.swarmSpeedPrefsKey))
        let respawnRadius² = respawnRadius*respawnRadius
        let queenVisible = (prefs.saverDefaults.bool(forKey: Prefs.queenVisiblePrefsKey))
        let swarmRainbow = (prefs.saverDefaults.bool(forKey: Prefs.swarmRainbowPrefsKey))
        let fade = (prefs.saverDefaults.float(forKey: Prefs.fadePrefsKey))
        
        context?.setFillColor(red: 0, green: 0, blue: 0, alpha: CGFloat(fade))
        context?.fill(self.bounds)
        
        context?.setBlendMode(CGBlendMode.lighten)
        context?.setLineWidth(5.0)
        context?.setLineCap(CGLineCap.butt)
        
        for d in swarm {
            // set vector towards queen
            // find closest queen, its difference vector, and magnitude
            let diff = queens.map { (q) -> (Bee, Vector, Float) in
                let diff = q.position - d.position
                return (q, diff, diff.mag²())
            }.min { (arg0, arg1) -> Bool in
                return arg0.2 < arg1.2
            }
            // re-spawn drone if it's too close to queen
            if (d.age > BeesSwiftView.ageLimit || (diff?.2)! < respawnRadius²) {
                d.position = randomCircularPoint(x: Float(self.bounds.width.native), y: Float(self.bounds.height.native))
                d.direction.x = 0
                d.direction.y = 0
                d.age = 0
                continue
            }
            // change direction vector to seek queen
            d.direction = d.direction + (diff?.1)! * swarmAcceleration
            // limit speed of drones
            let scale = d.direction.mag() / swarmSpeed
            if (scale > 1.0) {
                d.direction = d.direction / scale
            }
            // fade in by age
            
            let col = hsvToRgb(h: Float(d.age) / Float(BeesSwiftView.ageLimit), s: 1.0, v: 1.0)
            
            if (swarmRainbow) {
                context?.setStrokeColor(red: CGFloat(col.0), green: CGFloat(col.1), blue: CGFloat(col.2), alpha: CGFloat(min(Double(d.age) / BeesSwiftView.fadeIn, 1.0)))
                
            } else {
                context?.setStrokeColor(red: CGFloat(colour[0]), green: CGFloat(colour[1]), blue: CGFloat(colour[2]), alpha: CGFloat(min(Double(d.age) / BeesSwiftView.fadeIn, 1.0)))
            }
            
            context?.strokeLineSegments(between: [CGPoint(x: Double(d.position.x), y: Double(d.position.y)),
                                                  CGPoint(x: Double(d.position.x + d.direction.x), y: Double(d.position.y+d.direction.y))])
            d.step()
        }
        // animate queen
        context?.setBlendMode(CGBlendMode.normal)
        for q in queens {
            q.direction.x = Float(drand48())*queenSpeed-queenSpeed/2.0
            q.direction.y = Float(drand48())*queenSpeed-queenSpeed/2.0
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
            if (queenVisible) {
                context?.setStrokeColor(red: CGFloat(queenColour[0]), green: CGFloat(queenColour[1]), blue: CGFloat(queenColour[2]), alpha: CGFloat(queenColour[3]))
                context?.strokeLineSegments(between: [CGPoint(x: Double(q.position.x), y: Double(q.position.y)),
                                                      CGPoint(x: Double(q.position.x + q.direction.x), y: Double(q.position.y+q.direction.y))])
            }
            q.step()
            
        }
        NSGraphicsContext.current?.cgContext.draw(buffer!, at: CGPoint())
        
        self.image = (context!.makeImage())!
    }
    
    public override var hasConfigureSheet: Bool {
        get {
            NSLog("**** hasConfigureSheet ")
            return true
        }
    }
    
    public override var configureSheet:  NSWindow? {
        get {
            var objects = Optional.some( NSArray())
            Bundle.init(for: BeesSwiftView.self).loadNibNamed(NSNib.Name("ConfigureSheet"), owner: self.prefs, topLevelObjects: &objects)
            NSLog("**** configureSheet ")
            NSLog("**** configureSheet with %@", objects!)
            var prefsWindow: NSWindow?
            // TODO find a better way of getting the sheet instance
            for o in objects! {
                if (o is NSWindow) {
                    prefsWindow = o as? NSWindow
                }
                
            }
            prefs.configureSheet(prefsWindow: prefsWindow)
            return prefsWindow
        }
    }
}

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

    // prefs
    @IBOutlet weak var queenNumberSlider: NSSlider!
    @IBOutlet weak var swarmNumberSlider: NSSlider!
    @IBOutlet weak var queenSpeedSlider: NSSlider!
    @IBOutlet weak var swarmSpeedSlider: NSSlider!
    @IBOutlet weak var swarmAccelerationSlider: NSSlider!
    @IBOutlet weak var swarmRespawnRadiusSlider: NSSlider!
    @IBOutlet weak var fadeSlider: NSSlider!
    @IBOutlet weak var queenColorWell: NSColorWell!
    @IBOutlet weak var swarmColorWell: NSColorWell!
    static let queenNumberPrefsKey = "queenNumber"
    static let swarmNumberPrefsKey = "swarmNumber"
    static let queenSpeedPrefsKey = "queenSpeed"
    static let swarmSpeedPrefsKey = "swarmSpeed"
    static let swarmRespawnRadiusPrefsKey = "swarmRespawnRadius"
    static let swarmAccelerationPrefsKey = "swarmAcceleration"
    static let fadePrefsKey = "fade"
    static let queenColourPrefsKey = "queenColour"
    static let swarmColourPrefsKey = "swarmColour"
    var saverDefaults: ScreenSaverDefaults?

    // beezzz
    var queens = Array<Bee>()
    var swarm = Array<Bee>()
    
    // prefs window
    var prefsWindow: NSWindow?
    
    
    var image: CGImage?
    
    static let ageLimit = 300
    
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
        let defaults = [BeesSwiftView.queenNumberPrefsKey:1,
                        BeesSwiftView.swarmNumberPrefsKey:10,
                        BeesSwiftView.queenSpeedPrefsKey:5.710116731517509,
                        BeesSwiftView.swarmSpeedPrefsKey:3.162086575875486,
                        BeesSwiftView.swarmRespawnRadiusPrefsKey:0.2740454766536965,
                        BeesSwiftView.swarmAccelerationPrefsKey:0.008631748540856032,
                        BeesSwiftView.fadePrefsKey:0.06514469844357977,
                        BeesSwiftView.swarmColourPrefsKey:[0.0,0.0,1.0],
                        BeesSwiftView.queenColourPrefsKey:[1.0,0.4153324174586498,0.790315105986194,1.0]] as [String : Any]
        saverDefaults = ScreenSaverDefaults(forModuleWithName: Bundle.init(for: BeesSwiftView.self).bundleIdentifier!)
        NSLog("Saver defaults %@", saverDefaults ?? "nil")
        saverDefaults!.register(defaults: defaults)

        // seed queens in centre
        for _ in 1...(saverDefaults?.integer(forKey: BeesSwiftView.queenNumberPrefsKey))! {
            queens.append(Bee(v: Vector(x: Float(self.bounds.width.native)/2, y: Float(self.bounds.height.native)/2)))
        }
        // seed drones in random positions
        for _ in 1...(saverDefaults?.integer(forKey: BeesSwiftView.swarmNumberPrefsKey))!  {
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
        NSLog("in draw")
        super.draw(dirtyRect)
//            NSLog("get buffer")
            
        let buffer = CGLayer(NSGraphicsContext.current!.cgContext, size: frame.size, auxiliaryInfo: nil)
//            NSLog("got buffer")

//        let context = NSGraphicsContext.current?.cgContext
        let context = buffer?.context

        if (self.image != nil) {
            buffer?.context!.draw(image!, in: self.bounds)
        }

        context?.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.01)
        context?.fill(self.bounds)

//        NSLog("context %@", context.debugDescription)
        
//        NSLog("buffer %@", buffer.debugDescription)

        // animate swarm
        let colour = saverDefaults?.array(forKey: BeesSwiftView.swarmColourPrefsKey) as! [Double]
        let queenColour = saverDefaults?.array(forKey: BeesSwiftView.queenColourPrefsKey) as! [Double]
        let respawnRadius = (saverDefaults?.float(forKey: BeesSwiftView.swarmRespawnRadiusPrefsKey))!
        let swarmAcceleration = (saverDefaults?.float(forKey: BeesSwiftView.swarmAccelerationPrefsKey))!
        let queenSpeed = (saverDefaults?.float(forKey: BeesSwiftView.queenSpeedPrefsKey))!
        let swarmSpeed = (saverDefaults?.float(forKey: BeesSwiftView.swarmSpeedPrefsKey))!
        let respawnRadius² = respawnRadius*respawnRadius
        context?.setBlendMode(CGBlendMode.lighten)
        
        context?.setLineWidth(5.0)
        context?.setLineCap(CGLineCap.round)
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
//            let scale = d.direction.mag²() / (swarmSpeed*swarmSpeed)
            let scale = d.direction.mag() / swarmSpeed
            if (scale > 1.0) {
                d.direction = d.direction / scale
            }
            // fade in by age
            context?.setStrokeColor(red: CGFloat(colour[0]), green: CGFloat(colour[1]), blue: CGFloat(colour[2]), alpha: CGFloat(min(Double(d.age) / 300.0, 1.0)))
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
            context?.setStrokeColor(red: CGFloat(queenColour[0]), green: CGFloat(queenColour[1]), blue: CGFloat(queenColour[2]), alpha: CGFloat(queenColour[3]))
            context?.strokeLineSegments(between: [CGPoint(x: Double(q.position.x), y: Double(q.position.y)),
                                                  CGPoint(x: Double(q.position.x + q.direction.x), y: Double(q.position.y+q.direction.y))])
            q.step()

        }
        NSGraphicsContext.current?.cgContext.draw(buffer!, at: CGPoint())
        
        self.image = (context!.makeImage())!

    }
    
    public override var hasConfigureSheet: Bool {
        get {
            return true
        }
    }
    
    public override var configureSheet:  NSWindow? {
        get {
            var objects = Optional.some( NSArray())
            Bundle.init(for: BeesSwiftView.self).loadNibNamed(NSNib.Name("ConfigureSheet"), owner: self, topLevelObjects: &objects)
            NSLog("**** configureSheet with %@", objects!)
            for o in objects! {
                if (o is NSWindow) {
                    self.prefsWindow = o as? NSWindow
                }
            }
            self.queenNumberSlider.integerValue = (saverDefaults?.integer(forKey: BeesSwiftView.queenNumberPrefsKey))!
            self.swarmNumberSlider.integerValue = (saverDefaults?.integer(forKey: BeesSwiftView.swarmNumberPrefsKey))!
            self.queenSpeedSlider.doubleValue = (saverDefaults?.double(forKey: BeesSwiftView.queenSpeedPrefsKey))!
            self.swarmSpeedSlider.doubleValue = (saverDefaults?.double(forKey:BeesSwiftView.swarmSpeedPrefsKey))!
            self.swarmAccelerationSlider.doubleValue = (saverDefaults?.double(forKey:BeesSwiftView.swarmAccelerationPrefsKey))!
            self.swarmRespawnRadiusSlider.doubleValue = (saverDefaults?.double(forKey:BeesSwiftView.swarmRespawnRadiusPrefsKey))!
            self.fadeSlider.doubleValue = (saverDefaults?.double(forKey: BeesSwiftView.fadePrefsKey))!
            let colour = (saverDefaults?.array(forKey: BeesSwiftView.swarmColourPrefsKey)) as! [Double]
            self.swarmColorWell.color = NSColor(red: CGFloat(colour[0]), green: CGFloat(colour[1]), blue: CGFloat(colour[2]), alpha: 1.0)
            let queenColour = (saverDefaults?.array(forKey: BeesSwiftView.queenColourPrefsKey)) as! [Double]
            self.queenColorWell.color = NSColor(red: CGFloat(queenColour[0]), green: CGFloat(queenColour[1]), blue: CGFloat(queenColour[2]), alpha: CGFloat(queenColour[3]))
            NSLog("**** configureSheet with %@", prefsWindow ?? "nil")
            return prefsWindow
        }
    }
    
    @IBAction func onOk(_ sender: Any) {
        NSLog("**** onok with %@", prefsWindow ?? "nil")
        saverDefaults?.set(queenNumberSlider.integerValue, forKey: BeesSwiftView.queenNumberPrefsKey)
        saverDefaults?.set(swarmNumberSlider.integerValue, forKey: BeesSwiftView.swarmNumberPrefsKey)
        saverDefaults?.set(queenSpeedSlider.doubleValue, forKey: BeesSwiftView.queenSpeedPrefsKey)
        saverDefaults?.set(swarmSpeedSlider.doubleValue, forKey: BeesSwiftView.swarmSpeedPrefsKey)
        saverDefaults?.set(swarmAccelerationSlider.doubleValue, forKey: BeesSwiftView.swarmAccelerationPrefsKey)
        saverDefaults?.set(swarmRespawnRadiusSlider.doubleValue, forKey: BeesSwiftView.swarmRespawnRadiusPrefsKey)
        saverDefaults?.set(fadeSlider.doubleValue, forKey: BeesSwiftView.fadePrefsKey)
        saverDefaults?.set([swarmColorWell.color.redComponent.native, swarmColorWell.color.greenComponent.native, swarmColorWell.color.blueComponent.native], forKey: BeesSwiftView.swarmColourPrefsKey)
        saverDefaults?.set([queenColorWell.color.redComponent.native, queenColorWell.color.greenComponent.native, queenColorWell.color.blueComponent.native, queenColorWell.color.alphaComponent.native], forKey: BeesSwiftView.queenColourPrefsKey)
        NSColorPanel.shared.orderOut(self)
        // TODO figure out how to replace this deprecated method
        NSLog("on ok Saver defaults %@", saverDefaults ?? "nil")
        saverDefaults?.synchronize()
        NSApp.endSheet(prefsWindow!)
    }
    
}

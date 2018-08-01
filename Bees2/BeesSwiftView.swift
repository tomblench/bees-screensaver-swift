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
    @IBOutlet weak var queenSpeedSlider: NSSlider!
    @IBOutlet weak var swarmSpeedSlider: NSSlider!
    @IBOutlet weak var swarmAccelerationSlider: NSSlider!
    @IBOutlet weak var swarmRespawnRadiusSlider: NSSlider!
    @IBOutlet weak var fadeSlider: NSSlider!
    @IBOutlet weak var queenColorWell: NSColorWell!
    @IBOutlet weak var swarmColorWell: NSColorWell!
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


    override public init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        // seed queens in centre
        for _ in 1...10 {
            queens.append(Bee(x: Float(self.bounds.width.native/2.0), y: Float(self.bounds.height.native/2.0)))
        }
        // seed drones in random positions
        for _ in 1...250 {
            swarm.append(Bee(x: Float(drand48()*self.bounds.width.native), y: Float(drand48()*self.bounds.height.native)))
        }
        NSColor.white.set()
        NSRectFill(self.bounds)
        // use our bundle id to register defaults
        NSLog("Bundle name %@", Bundle.init(for: BeesSwiftView.self).bundleIdentifier!)
        let defaults = [BeesSwiftView.queenSpeedPrefsKey:18.30617704280156,
                        BeesSwiftView.swarmSpeedPrefsKey:9.721546692607003,
                        BeesSwiftView.swarmRespawnRadiusPrefsKey:3.0,
                        BeesSwiftView.swarmAccelerationPrefsKey:0.02338430204280156,
                        BeesSwiftView.fadePrefsKey:0.06514469844357977,
                        BeesSwiftView.swarmColourPrefsKey:[0.0,0.0,1.0],
                        BeesSwiftView.queenColourPrefsKey:[1.0,0.0,0.0,1.0]] as [String : Any]
        saverDefaults = ScreenSaverDefaults(forModuleWithName: Bundle.init(for: BeesSwiftView.self).bundleIdentifier!)
        NSLog("Saver defaults %@", saverDefaults ?? "nil")
        saverDefaults!.register(defaults: defaults)

    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func animateOneFrame() {
        // clear background
        let context = NSGraphicsContext.current()?.cgContext
        context?.setFillColor(CGColor.black.copy(alpha: CGFloat((saverDefaults?.double(forKey: BeesSwiftView.fadePrefsKey))!))!)
        context?.setBlendMode(CGBlendMode.normal)
        context?.fill(self.bounds)
        // animate swarm
        let colour = saverDefaults?.array(forKey: BeesSwiftView.swarmColourPrefsKey) as! [Double]
        let queenColour = saverDefaults?.array(forKey: BeesSwiftView.queenColourPrefsKey) as! [Double]
        let respawnRadius = (saverDefaults?.float(forKey: BeesSwiftView.swarmRespawnRadiusPrefsKey))!
        let swarmAcceleration = (saverDefaults?.float(forKey: BeesSwiftView.swarmAccelerationPrefsKey))!
        let queenSpeed = (saverDefaults?.float(forKey: BeesSwiftView.queenSpeedPrefsKey))!
        let swarmSpeed = (saverDefaults?.float(forKey: BeesSwiftView.swarmSpeedPrefsKey))!
        for d in swarm {
            // set vector towards queen
            // find closest queen, its difference vector, and magnitude
            let diff = queens.map { (q) -> (Bee, Vector, Float) in
                let diff = q.position - d.position
                return (q, diff, diff.mag())
            }.min { (arg0, arg1) -> Bool in
                return arg0.2 < arg1.2
            }
            // re-spawn drone if it's too close to queen
            if ((diff?.2)! < respawnRadius) {
                d.position.x = Float(drand48()*self.bounds.width.native)
                d.position.y = Float(drand48()*self.bounds.height.native)
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
            d.step()
            // fade in by age
            context?.setFillColor(red: CGFloat(colour[0]), green: CGFloat(colour[1]), blue: CGFloat(colour[2]), alpha: CGFloat(min(Double(d.age) / 300.0, 1.0)))
            context?.setBlendMode(CGBlendMode.lighten)
            context?.addEllipse(in: NSRect(x: Double(d.position.x), y: Double(d.position.y), width: 5.0, height: 5.0))
            context?.fillPath()
        }
        // animate queen
        for q in queens {
            context?.setBlendMode(CGBlendMode.normal)
            q.direction.x = Float(drand48())*queenSpeed-queenSpeed/2.0
            q.direction.y = Float(drand48())*queenSpeed-queenSpeed/2.0
            q.step()
            // wrap
            if (q.position.x < 0) {
                q.position.x = Float(self.bounds.width)
            }
            if (q.position.x > Float(self.bounds.width)) {
                q.position.x = 0
            }
            if (q.position.y < 0) {
                q.position.y = Float(self.bounds.height)
            }
            if (q.position.y > Float(self.bounds.height)) {
                q.position.y = 0
            }
            context?.setFillColor(red: CGFloat(queenColour[0]), green: CGFloat(queenColour[1]), blue: CGFloat(queenColour[2]), alpha: CGFloat(queenColour[3]))
            context?.setBlendMode(CGBlendMode.normal)
            context?.addEllipse(in: NSRect(x: Double(q.position.x), y: Double(q.position.y), width: 5.0, height: 5.0))
            context?.fillPath()
        }

    }

    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    public override func hasConfigureSheet() -> Bool {
        return true
    }
    
    public override func configureSheet() -> NSWindow? {
        var objects = NSArray()
        Bundle.init(for: BeesSwiftView.self).loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: &objects)
        NSLog("**** configureSheet with %@", objects)
        for o in objects {
            if (o is NSWindow) {
                self.prefsWindow = o as? NSWindow
            }
        }
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
    
    @IBAction func onOk(_ sender: Any) {
        NSLog("**** onok with %@", prefsWindow ?? "nil")
        saverDefaults?.set(queenSpeedSlider.doubleValue, forKey: BeesSwiftView.queenSpeedPrefsKey)
        saverDefaults?.set(swarmSpeedSlider.doubleValue, forKey: BeesSwiftView.swarmSpeedPrefsKey)
        saverDefaults?.set(swarmAccelerationSlider.doubleValue, forKey: BeesSwiftView.swarmAccelerationPrefsKey)
        saverDefaults?.set(swarmRespawnRadiusSlider.doubleValue, forKey: BeesSwiftView.swarmRespawnRadiusPrefsKey)
        saverDefaults?.set(fadeSlider.doubleValue, forKey: BeesSwiftView.fadePrefsKey)
        saverDefaults?.set([swarmColorWell.color.redComponent.native, swarmColorWell.color.greenComponent.native, swarmColorWell.color.blueComponent.native], forKey: BeesSwiftView.swarmColourPrefsKey)
        saverDefaults?.set([queenColorWell.color.redComponent.native, queenColorWell.color.greenComponent.native, queenColorWell.color.blueComponent.native, queenColorWell.color.alphaComponent.native], forKey: BeesSwiftView.queenColourPrefsKey)
        NSColorPanel.shared().orderOut(self)
        // TODO figure out how to replace this deprecated method
        NSLog("on ok Saver defaults %@", saverDefaults ?? "nil")
        saverDefaults?.synchronize()
        NSApp.endSheet(prefsWindow!)
    }
    
}

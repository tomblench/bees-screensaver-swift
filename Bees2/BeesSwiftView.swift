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
    static let queenSpeedPrefsKey = "org.blench.bees.queenSpeed"
    static let swarmSpeedPrefsKey = "org.blench.bees.swarmSpeed"
    static let swarmRespawnRadiusPrefsKey = "org.blench.bees.swarmRespawnRadius"
    static let swarmAccelerationPrefsKey = "org.blench.bees.swarmAcceleration"
    static let fadePrefsKey = "org.blench.bees.fade"
    static let swarmColourPrefsKey = "org.blench.bees.swarmColour"
    var defaults = [queenSpeedPrefsKey:18.30617704280156,
                    swarmSpeedPrefsKey:9.721546692607003,
                    swarmRespawnRadiusPrefsKey:3.0,
                    swarmAccelerationPrefsKey:0.02338430204280156,
                    fadePrefsKey:0.06514469844357977,
                    swarmColourPrefsKey:[0.0,0.0,1.0]] as [String : Any]
    // beezzz
    var queens = Array<Bee>()
    var swarm = Array<Bee>()
    
    // prefs window
    var prefsWindow: NSWindow?


    override public init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        // seed queens in centre
        for _ in 1...10 {
            queens.append(Bee(x: self.bounds.width.native/2.0, y: self.bounds.height.native/2.0))
        }
        // seed drones in random positions
        for _ in 1...250 {
            swarm.append(Bee(x: drand48()*self.bounds.width.native, y: drand48()*self.bounds.height.native))
        }
        NSColor.white.set()
        NSRectFill(self.bounds)
        UserDefaults.standard.register(defaults: defaults)
        defaults = UserDefaults.standard.dictionaryRepresentation()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func animateOneFrame() {
        // clear background
        NSColor.black.withAlphaComponent(CGFloat(defaults[BeesSwiftView.fadePrefsKey] as! Double)).set()
        NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver)
        // animate swarm
        // TODO use a compositing mode so that dark bees don't block light ones
        // OR respawn new bees by adding to them at the beginning of the list and draw them first
        for d in swarm {
            // fade in by age
            //swarmColour.withAlphaComponent(CGFloat(min(Double(d.age) / 300.0, 1.0))).set()
            let colour = defaults[BeesSwiftView.swarmColourPrefsKey] as! [Double]
            NSColor.init(red: CGFloat(colour[0]), green: CGFloat(colour[1]), blue: CGFloat(colour[2]), alpha: CGFloat(min(Double(d.age) / 300.0, 1.0))).set()
            // set vector towards queen
            // TODO rewrite "functionally"
            var diff = Vector(x: Double.greatestFiniteMagnitude, y: Double.greatestFiniteMagnitude)
            for q in queens {
                // find closest
                let curDiff = q.position - d.position
                if (curDiff.mag() < diff.mag()) {
                    diff = curDiff
                }
            }
            // re-spawn drone if it's too close to queen
            if (diff.mag() < (defaults[BeesSwiftView.swarmRespawnRadiusPrefsKey] as! Double)) {
                d.position.x = drand48()*self.bounds.width.native
                d.position.y = drand48()*self.bounds.height.native
                d.direction.x = 0
                d.direction.y = 0
                d.age = 0
                continue
            }
            // change direction vector to seek queen
            d.direction = d.direction + diff * (defaults[BeesSwiftView.swarmAccelerationPrefsKey] as! Double)
            // limit speed of drones
            let scale = d.direction.mag() / (defaults[BeesSwiftView.swarmSpeedPrefsKey] as! Double)
            if (scale > 1.0) {
                d.direction = d.direction / scale
            }
            d.step()
            NSRectFill(NSRect(x: d.position.x, y: d.position.y, width: 5.0, height: 5.0))
        }
        // animate queen
//        NSColor.red.set()
        for q in queens {
            let qs = defaults[BeesSwiftView.queenSpeedPrefsKey] as! Double
            q.direction.x = drand48()*qs-qs/2.0
            q.direction.y = drand48()*qs-qs/2.0
            q.step()
            // wrap
            if (q.position.x < 0) {
                q.position.x = Double(self.bounds.width)
            }
            if (q.position.x > Double(self.bounds.width)) {
                q.position.x = 0
            }
            if (q.position.y < 0) {
                q.position.y = Double(self.bounds.height)
            }
            if (q.position.y > Double(self.bounds.height)) {
                q.position.y = 0
            }
//            NSRectFill(NSRect(x: q.position.x, y: q.position.y, width: 5.0, height: 5.0))
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
        self.queenSpeedSlider.doubleValue = defaults[BeesSwiftView.queenSpeedPrefsKey] as! Double
        self.swarmSpeedSlider.doubleValue = defaults[BeesSwiftView.swarmSpeedPrefsKey] as! Double
        self.swarmAccelerationSlider.doubleValue = defaults[BeesSwiftView.swarmAccelerationPrefsKey] as! Double
        self.swarmRespawnRadiusSlider.doubleValue = defaults[BeesSwiftView.swarmRespawnRadiusPrefsKey] as! Double
        self.fadeSlider.doubleValue = defaults[BeesSwiftView.fadePrefsKey] as! Double
        let colour = defaults[BeesSwiftView.swarmColourPrefsKey] as! [Double]
        self.swarmColorWell.color = NSColor(red: CGFloat(colour[0]), green: CGFloat(colour[1]), blue: CGFloat(colour[2]), alpha: 1.0)
        NSLog("**** configureSheet with %@", prefsWindow ?? "nil")
        return prefsWindow
    }
    
    @IBAction func onOk(_ sender: Any) {
        NSLog("**** onok with %@", prefsWindow ?? "nil")
        defaults[BeesSwiftView.queenSpeedPrefsKey] = queenSpeedSlider.doubleValue
        defaults[BeesSwiftView.swarmSpeedPrefsKey] = swarmSpeedSlider.doubleValue
        defaults[BeesSwiftView.swarmAccelerationPrefsKey] = swarmAccelerationSlider.doubleValue
        defaults[BeesSwiftView.swarmRespawnRadiusPrefsKey] = swarmRespawnRadiusSlider.doubleValue
        defaults[BeesSwiftView.fadePrefsKey] = fadeSlider.doubleValue
        defaults[BeesSwiftView.swarmColourPrefsKey] = [swarmColorWell.color.redComponent.native, swarmColorWell.color.greenComponent.native, swarmColorWell.color.blueComponent.native]
        NSColorPanel.shared().orderOut(self)
        UserDefaults.standard.setValuesForKeys(defaults)
        // TODO figure out how to replace this deprecated method
        NSApp.endSheet(prefsWindow!)
    }
    
}

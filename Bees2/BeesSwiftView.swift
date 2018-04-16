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
            queens.append(Bee(x: self.bounds.width.native/2.0, y: self.bounds.height.native/2.0))
        }
        // seed drones in random positions
        for _ in 1...250 {
            swarm.append(Bee(x: drand48()*self.bounds.width.native, y: drand48()*self.bounds.height.native))
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
                        BeesSwiftView.swarmColourPrefsKey:[0.0,0.0,1.0]] as [String : Any]
        saverDefaults = ScreenSaverDefaults(forModuleWithName: Bundle.init(for: BeesSwiftView.self).bundleIdentifier!)
        NSLog("Saver defaults %@", saverDefaults ?? "nil")
        saverDefaults!.register(defaults: defaults)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func animateOneFrame() {
        // clear background
        NSColor.black.withAlphaComponent(CGFloat((saverDefaults?.double(forKey: BeesSwiftView.fadePrefsKey))!)).set()
        NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver)
        // animate swarm
        // TODO use a compositing mode so that dark bees don't block light ones
        // OR respawn new bees by adding to them at the beginning of the list and draw them first
        let colour = saverDefaults?.array(forKey: BeesSwiftView.swarmColourPrefsKey) as! [Double]
        let respawnRadius = (saverDefaults?.double(forKey: BeesSwiftView.swarmRespawnRadiusPrefsKey))!
        let swarmAcceleration = (saverDefaults?.double(forKey: BeesSwiftView.swarmAccelerationPrefsKey))!
        let queenSpeed = (saverDefaults?.double(forKey: BeesSwiftView.queenSpeedPrefsKey))!
        let swarmSpeed = (saverDefaults?.double(forKey: BeesSwiftView.swarmSpeedPrefsKey))!
        for d in swarm {
            // fade in by age
            //swarmColour.withAlphaComponent(CGFloat(min(Double(d.age) / 300.0, 1.0))).set()
            NSColor.init(red: CGFloat(colour[0]), green: CGFloat(colour[1]), blue: CGFloat(colour[2]), alpha: CGFloat(min(Double(d.age) / 300.0, 1.0))).set()
            // set vector towards queen
            // find closest queen, its difference vector, and magnitude
            let diff = queens.map { (q) -> (Bee, Vector, Double) in
                let diff = q.position - d.position
                return (q, diff, diff.mag())
            }.min { (arg0, arg1) -> Bool in
                return arg0.2 < arg1.2
            }
            // re-spawn drone if it's too close to queen
            if ((diff?.2)! < respawnRadius) {
                d.position.x = drand48()*self.bounds.width.native
                d.position.y = drand48()*self.bounds.height.native
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
            NSRectFill(NSRect(x: d.position.x, y: d.position.y, width: 5.0, height: 5.0))
        }
        // animate queen
//        NSColor.red.set()
        for q in queens {
            q.direction.x = drand48()*queenSpeed-queenSpeed/2.0
            q.direction.y = drand48()*queenSpeed-queenSpeed/2.0
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
        self.queenSpeedSlider.doubleValue = (saverDefaults?.double(forKey: BeesSwiftView.queenSpeedPrefsKey))!
        self.swarmSpeedSlider.doubleValue = (saverDefaults?.double(forKey:BeesSwiftView.swarmSpeedPrefsKey))!
        self.swarmAccelerationSlider.doubleValue = (saverDefaults?.double(forKey:BeesSwiftView.swarmAccelerationPrefsKey))!
        self.swarmRespawnRadiusSlider.doubleValue = (saverDefaults?.double(forKey:BeesSwiftView.swarmRespawnRadiusPrefsKey))!
        self.fadeSlider.doubleValue = (saverDefaults?.double(forKey: BeesSwiftView.fadePrefsKey))!
        let colour = (saverDefaults?.array(forKey: BeesSwiftView.swarmColourPrefsKey)) as! [Double]
        self.swarmColorWell.color = NSColor(red: CGFloat(colour[0]), green: CGFloat(colour[1]), blue: CGFloat(colour[2]), alpha: 1.0)
        NSLog("**** configureSheet with %@", prefsWindow ?? "nil")
        return prefsWindow
    }
    
    @IBAction func onOk(_ sender: Any) {
        NSLog("**** onok with %@", prefsWindow ?? "nil")
        saverDefaults?.setValue(queenSpeedSlider.doubleValue, forKey: BeesSwiftView.queenSpeedPrefsKey)
        saverDefaults?.setValue(swarmAccelerationSlider.doubleValue, forKey: BeesSwiftView.swarmAccelerationPrefsKey)
        saverDefaults?.setValue(swarmRespawnRadiusSlider.doubleValue, forKey: BeesSwiftView.swarmRespawnRadiusPrefsKey)
        saverDefaults?.setValue(fadeSlider.doubleValue, forKey: BeesSwiftView.fadePrefsKey)
        saverDefaults?.setValue([swarmColorWell.color.redComponent.native, swarmColorWell.color.greenComponent.native, swarmColorWell.color.blueComponent.native], forKey: BeesSwiftView.swarmColourPrefsKey)
        NSColorPanel.shared().orderOut(self)
        // TODO figure out how to replace this deprecated method
        NSLog("on ok Saver defaults %@", saverDefaults ?? "nil")
        NSApp.endSheet(prefsWindow!)
    }
    
}

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
    var queenSpeed = 20.0
    var swarmSpeed = 5.0
    var swarmRespawnRadius = 2.0
    var swarmAcceleration = 0.01
    var fade = 0.3
    var swarmColour = NSColor.blue
    let queenSpeedPrefsKey = "org.blench.bees.queenSpeed"
    let swarmSpeedPrefsKey = "org.blench.bees.swarmSpeed"
    let swarmRespawnRadiusPrefsKey = "org.blench.bees.swarmRespawnRadius"
    let swarmAccelerationPrefsKey = "org.blench.bees.swarmAcceleration"
    let fadePrefsKey = "org.blench.bees.fade"
    
    // beezzz
    let queen = Bee()
    var swarm = Array<Bee>()
    
    // prefs window
    var prefsWindow: NSWindow?


    override public init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        // seed queen in centre
        queen.position.x = self.bounds.width.native/2.0
        queen.position.y = self.bounds.height.native/2.0
        // seed drones in random positions
        for _ in 1...250 {
            swarm.append(Bee(x: drand48()*self.bounds.width.native, y: drand48()*self.bounds.height.native))
        }
        NSColor.white.set()
        NSRectFill(self.bounds)
        if (UserDefaults.standard.bool(forKey: queenSpeedPrefsKey)) {
            queenSpeed = UserDefaults.standard.double(forKey: queenSpeedPrefsKey)
        }
        if (UserDefaults.standard.bool(forKey: swarmSpeedPrefsKey)) {
            swarmSpeed = UserDefaults.standard.double(forKey: swarmSpeedPrefsKey)
        }
        if (UserDefaults.standard.bool(forKey: swarmAccelerationPrefsKey)) {
            swarmAcceleration = UserDefaults.standard.double(forKey: swarmAccelerationPrefsKey)
        }
        if (UserDefaults.standard.bool(forKey: swarmRespawnRadiusPrefsKey)) {
            swarmRespawnRadius = UserDefaults.standard.double(forKey: swarmRespawnRadiusPrefsKey)
        }
        if (UserDefaults.standard.bool(forKey: fadePrefsKey)) {
            fade = UserDefaults.standard.double(forKey: fadePrefsKey)
        }

    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func animateOneFrame() {
        // clear background
        NSColor.black.withAlphaComponent(CGFloat(fade)).set()
        NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver)
        // animate swarm
        for d in swarm {
            // fade in by age
            swarmColour.withAlphaComponent(CGFloat(min(Double(d.age) / 300.0, 1.0))).set()
            // set vector towards queen
            let diff = queen.position - d.position
            // re-spawn drone if it's too close to queen
            if (diff.mag() < swarmRespawnRadius) {
                d.position.x = drand48()*self.bounds.width.native
                d.position.y = drand48()*self.bounds.height.native
                d.direction.x = 0
                d.direction.y = 0
                d.age = 0
                continue
            }
            // change direction vector to seek queen
            d.direction = d.direction + diff * swarmAcceleration
            // limit speed of drones
            let scale = d.direction.mag() / swarmSpeed
            if (scale > 1.0) {
                d.direction = d.direction / scale
            }
            d.step()
            NSRectFill(NSRect(x: d.position.x, y: d.position.y, width: 5.0, height: 5.0))
        }
        // animate queen
        //NSColor.red.set()
        queen.direction.x = drand48()*queenSpeed-queenSpeed/2.0
        queen.direction.y = drand48()*queenSpeed-queenSpeed/2.0
        queen.step()
        //NSRectFill(NSRect(x: queen.position.x, y: queen.position.y, width: 5.0, height: 5.0))

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
        self.queenSpeedSlider.doubleValue = queenSpeed
        self.swarmSpeedSlider.doubleValue = swarmSpeed
        self.swarmAccelerationSlider.doubleValue = swarmAcceleration
        self.swarmRespawnRadiusSlider.doubleValue = swarmRespawnRadius
        self.fadeSlider.doubleValue = fade
        NSLog("**** configureSheet with %@", prefsWindow ?? "nil")
        return prefsWindow
    }
    
    @IBAction func onOk(_ sender: Any) {
        NSLog("**** onok with %@", prefsWindow ?? "nil")
        self.queenSpeed = queenSpeedSlider.doubleValue
        self.swarmSpeed = swarmSpeedSlider.doubleValue
        self.swarmAcceleration = swarmAccelerationSlider.doubleValue
        self.swarmRespawnRadius = swarmRespawnRadiusSlider.doubleValue
        self.fade = fadeSlider.doubleValue
        self.swarmColour = swarmColorWell.color
        NSColorPanel.shared().orderOut(self)
        UserDefaults.standard.set(self.queenSpeed, forKey: queenSpeedPrefsKey)
        UserDefaults.standard.set(self.swarmSpeed, forKey: swarmSpeedPrefsKey)
        UserDefaults.standard.set(self.swarmAcceleration, forKey: swarmAccelerationPrefsKey)
        UserDefaults.standard.set(self.swarmRespawnRadius, forKey: swarmRespawnRadiusPrefsKey)
        UserDefaults.standard.set(self.fade, forKey: fadePrefsKey)
        // TODO figure out how to replace this deprecated method
        NSApp.endSheet(prefsWindow!)
    }
    
}

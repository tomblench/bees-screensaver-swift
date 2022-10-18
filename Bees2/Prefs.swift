//
//  Prefs.swift
//  Bees2
//
//  Created by Thomas Blench on 18/10/2022.
//  Copyright © 2022 Thomas Blench. All rights reserved.
//

import Foundation
import AppKit
import ScreenSaver

public class Prefs : NSObject {
    var prefsWindow: NSWindow!

    @IBOutlet weak var queenNumberSlider: NSTextField!
    @IBOutlet weak var swarmNumberSlider: NSTextField!
    @IBOutlet weak var queenSpeedSlider: NSSlider!
    @IBOutlet weak var swarmSpeedSlider: NSSlider!
    @IBOutlet weak var swarmAccelerationSlider: NSSlider!
    @IBOutlet weak var swarmRespawnRadiusSlider: NSSlider!
    @IBOutlet weak var fadeSlider: NSSlider!
    @IBOutlet weak var queenColorWell: NSColorWell!
    @IBOutlet weak var swarmColorWell: NSColorWell!
    @IBOutlet weak var swarmRainbowCheckbox: NSButton!
    @IBOutlet weak var queenVisibleCheckbox: NSButton!
    
    public var saverDefaults = ScreenSaverDefaults(forModuleWithName: Bundle.init(for: Prefs.self).bundleIdentifier!)!
    
    public static let queenNumberPrefsKey = "queenNumber"
    public static let swarmNumberPrefsKey = "swarmNumber"
    public static let queenSpeedPrefsKey = "queenSpeed"
    public static let swarmSpeedPrefsKey = "swarmSpeed"
    public static let swarmRespawnRadiusPrefsKey = "swarmRespawnRadius"
    public static let swarmAccelerationPrefsKey = "swarmAcceleration"
    public static let fadePrefsKey = "fade"
    public static let queenColourPrefsKey = "queenColour"
    public static let queenVisiblePrefsKey = "queenVisible"
    public static let swarmColourPrefsKey = "swarmColour"
    public static let swarmRainbowPrefsKey = "swarmRainbow"
    
    public func configureSheet(prefsWindow: NSWindow!) {
        self.prefsWindow = prefsWindow
        self.queenNumberSlider.integerValue = (saverDefaults.integer(forKey: Prefs.queenNumberPrefsKey))
            self.swarmNumberSlider.integerValue = (saverDefaults.integer(forKey: Prefs.swarmNumberPrefsKey))
            self.queenSpeedSlider.doubleValue = (saverDefaults.double(forKey: Prefs.queenSpeedPrefsKey))
            self.swarmSpeedSlider.doubleValue = (saverDefaults.double(forKey:Prefs.swarmSpeedPrefsKey))
            self.swarmAccelerationSlider.doubleValue = (saverDefaults.double(forKey:Prefs.swarmAccelerationPrefsKey))
            self.swarmRespawnRadiusSlider.doubleValue = (saverDefaults.double(forKey:Prefs.swarmRespawnRadiusPrefsKey))
            self.fadeSlider.doubleValue = (saverDefaults.double(forKey: Prefs.fadePrefsKey))
            let colour = (saverDefaults.array(forKey: Prefs.swarmColourPrefsKey)) as! [Double]
            self.swarmColorWell.color = NSColor(red: CGFloat(colour[0]), green: CGFloat(colour[1]), blue: CGFloat(colour[2]), alpha: 1.0)
            let queenColour = (saverDefaults.array(forKey: Prefs.queenColourPrefsKey)) as! [Double]
            self.queenColorWell.color = NSColor(red: CGFloat(queenColour[0]), green: CGFloat(queenColour[1]), blue: CGFloat(queenColour[2]), alpha: CGFloat(queenColour[3]))
            self.queenVisibleCheckbox.state = (saverDefaults.bool(forKey: Prefs.queenVisiblePrefsKey)) == true ? NSControl.StateValue.on : NSControl.StateValue.off
            self.swarmRainbowCheckbox.state = (saverDefaults.bool(forKey: Prefs.swarmRainbowPrefsKey)) == true ? NSControl.StateValue.on : NSControl.StateValue.off
            NSLog("**** configureSheet with %@", prefsWindow ?? "nil")
                
            onQueenVisibleToggle(Void.self)
            onSwarmRainbowToggle(Void.self)
    }
    
    @IBAction func onOk(_ sender: Any) {
        NSLog("**** onok with %@", prefsWindow ?? "nil")
        saverDefaults.set(queenNumberSlider.integerValue, forKey: Prefs.queenNumberPrefsKey)
        saverDefaults.set(swarmNumberSlider.integerValue, forKey: Prefs.swarmNumberPrefsKey)
        saverDefaults.set(queenSpeedSlider.doubleValue, forKey: Prefs.queenSpeedPrefsKey)
        saverDefaults.set(swarmSpeedSlider.doubleValue, forKey: Prefs.swarmSpeedPrefsKey)
        saverDefaults.set(swarmAccelerationSlider.doubleValue, forKey: Prefs.swarmAccelerationPrefsKey)
        saverDefaults.set(swarmRespawnRadiusSlider.doubleValue, forKey: Prefs.swarmRespawnRadiusPrefsKey)
        saverDefaults.set(fadeSlider.doubleValue, forKey: Prefs.fadePrefsKey)
        saverDefaults.set([swarmColorWell.color.redComponent.native, swarmColorWell.color.greenComponent.native, swarmColorWell.color.blueComponent.native], forKey: Prefs.swarmColourPrefsKey)
        saverDefaults.set([queenColorWell.color.redComponent.native, queenColorWell.color.greenComponent.native, queenColorWell.color.blueComponent.native, queenColorWell.color.alphaComponent.native], forKey: Prefs.queenColourPrefsKey)
        saverDefaults.set(queenVisibleCheckbox.state == NSControl.StateValue.on ? true : false, forKey: Prefs.queenVisiblePrefsKey)
        saverDefaults.set(swarmRainbowCheckbox.state == NSControl.StateValue.on ? true : false, forKey: Prefs.swarmRainbowPrefsKey)

        NSColorPanel.shared.orderOut(self)
        // TODO figure out how to replace this deprecated method
        NSLog("on ok Saver defaults %@", saverDefaults ?? "nil")
        saverDefaults.synchronize()
//        prefsWindow.endSheet(prefsWindow)
        NSApp.endSheet(prefsWindow!)
    }
    
    @IBAction func onQueenVisibleToggle(_ sender: Any) {
        queenColorWell.isEnabled = queenVisibleCheckbox.state == NSControl.StateValue.on ? true : false
    }

    @IBAction func onSwarmRainbowToggle(_ sender: Any) {
        swarmColorWell.isEnabled = swarmRainbowCheckbox.state == NSControl.StateValue.on ? true : false
    }
    
}

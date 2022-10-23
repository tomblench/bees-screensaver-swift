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
    
    public var saverDefaults = ScreenSaverDefaults(forModuleWithName: Bundle.init(for: Prefs.self).bundleIdentifier!)!

    @IBOutlet weak var sheet: NSWindow!

    @IBOutlet weak var presetsComboBox: NSPopUpButton!
    @IBOutlet weak var queenNumberSlider: NSSlider!
    @IBOutlet weak var queenColorWell: NSColorWell!
    @IBOutlet weak var queenVisibleCheckbox: NSButton!
    @IBOutlet weak var queenSpeedSlider: NSSlider!
    @IBOutlet weak var swarmNumberSlider: NSSlider!
    @IBOutlet weak var swarmColorWell: NSColorWell!
    @IBOutlet weak var swarmRainbowCheckbox: NSButton!
    @IBOutlet weak var swarmSpeedSlider: NSSlider!
    @IBOutlet weak var swarmAccelerationSlider: NSSlider!
    @IBOutlet weak var swarmRespawnRadiusSlider: NSSlider!
    @IBOutlet weak var fadeSlider: NSSlider!
    
    public static let queenNumberPrefsKey = "queenNumber"
    public static let queenColourPrefsKey = "queenColour"
    public static let queenVisiblePrefsKey = "queenVisible"
    public static let queenSpeedPrefsKey = "queenSpeed"
    public static let swarmNumberPrefsKey = "swarmNumber"
    public static let swarmColourPrefsKey = "swarmColour"
    public static let swarmRainbowPrefsKey = "swarmRainbow"
    public static let swarmSpeedPrefsKey = "swarmSpeed"
    public static let swarmAccelerationPrefsKey = "swarmAcceleration"
    public static let swarmRespawnRadiusPrefsKey = "swarmRespawnRadius"
    public static let fadePrefsKey = "fade"
    
    // these are both the "unpacked" vars for use in the animation and the initial values for defaults
    var queenNumber = 1
    var queenColour = [1.0, 0.0, 0.0]
    var queenVisible = false
    var queenSpeed: Float = 100.0
    var swarmNumber = 200
    var swarmColour = [0.0, 1.0, 0.0]
    var swarmRainbow = false
    var swarmSpeed: Float = 50.0
    var swarmAcceleration: Float = 0.01
    var respawnRadius: Float = 100.0
    var fadeLinear: Float = 4.0

    // these are derived and don't need defaults
    var respawnRadius²: Float = 0.0
    var fade: Float = 0.0
    
    // NB this must be the same as the slider range for fade - [0..fadePower]
    static let fadePower: Float = 8.0
    
    public override init() {
        let defaults = [Prefs.queenNumberPrefsKey: queenNumber,
                        Prefs.queenColourPrefsKey: queenColour,
                        Prefs.queenVisiblePrefsKey: queenVisible,
                        Prefs.queenSpeedPrefsKey: queenSpeed,
                        Prefs.swarmNumberPrefsKey: swarmNumber,
                        Prefs.swarmColourPrefsKey: swarmColour,
                        Prefs.swarmRainbowPrefsKey: swarmRainbow,
                        Prefs.swarmSpeedPrefsKey: swarmSpeed,
                        Prefs.swarmAccelerationPrefsKey: swarmAcceleration,
                        Prefs.swarmRespawnRadiusPrefsKey: respawnRadius,
                        Prefs.fadePrefsKey: fadeLinear] as [String : Any]
        saverDefaults.register(defaults: defaults)
        NSLog("init saver defaults %@", saverDefaults)
    }
    
    public override func awakeFromNib() {
        for k in PrefsPresets.presets.keys {
            self.presetsComboBox.addItem(withTitle: k)
        }
    }
    
    // sync "unpacked" and derived fields for easy access from the View
    public func syncPrefsToFields() {
        queenNumber = saverDefaults.integer(forKey: Prefs.queenNumberPrefsKey)
        queenColour = saverDefaults.array(forKey: Prefs.queenColourPrefsKey) as! [Double]
        queenVisible = saverDefaults.bool(forKey: Prefs.queenVisiblePrefsKey)
        queenSpeed = saverDefaults.float(forKey: Prefs.queenSpeedPrefsKey)
        swarmNumber = saverDefaults.integer(forKey: Prefs.swarmNumberPrefsKey)
        swarmColour = saverDefaults.array(forKey: Prefs.swarmColourPrefsKey) as! [Double]
        swarmRainbow = saverDefaults.bool(forKey: Prefs.swarmRainbowPrefsKey)
        swarmSpeed = saverDefaults.float(forKey: Prefs.swarmSpeedPrefsKey)
        swarmAcceleration = saverDefaults.float(forKey: Prefs.swarmAccelerationPrefsKey)
        respawnRadius = saverDefaults.float(forKey: Prefs.swarmRespawnRadiusPrefsKey)
        fadeLinear = saverDefaults.float(forKey: Prefs.fadePrefsKey)
        
        // derived preference values
        respawnRadius² = respawnRadius*respawnRadius
        fade = powf(2.0, fadeLinear - Prefs.fadePower)
    }
    
    // sync UI from defaults
    public func configureSheet() {
        self.queenNumberSlider.integerValue = (saverDefaults.integer(forKey: Prefs.queenNumberPrefsKey))
        let qc = (saverDefaults.array(forKey: Prefs.queenColourPrefsKey)) as! [Double]
        self.queenColorWell.color = NSColor(red: CGFloat(qc[0]), green: CGFloat(qc[1]), blue: CGFloat(qc[2]), alpha: 1.0)
        self.queenVisibleCheckbox.state = (saverDefaults.bool(forKey: Prefs.queenVisiblePrefsKey)) == true ? NSControl.StateValue.on : NSControl.StateValue.off
        self.queenSpeedSlider.doubleValue = (saverDefaults.double(forKey: Prefs.queenSpeedPrefsKey))
        self.swarmNumberSlider.integerValue = (saverDefaults.integer(forKey: Prefs.swarmNumberPrefsKey))
        let sc = (saverDefaults.array(forKey: Prefs.swarmColourPrefsKey)) as! [Double]
        self.swarmColorWell.color = NSColor(red: CGFloat(sc[0]), green: CGFloat(sc[1]), blue: CGFloat(sc[2]), alpha: 1.0)
        self.swarmRainbowCheckbox.state = (saverDefaults.bool(forKey: Prefs.swarmRainbowPrefsKey)) == true ? NSControl.StateValue.on : NSControl.StateValue.off
        self.swarmSpeedSlider.doubleValue = (saverDefaults.double(forKey:Prefs.swarmSpeedPrefsKey))
        self.swarmAccelerationSlider.doubleValue = (saverDefaults.double(forKey:Prefs.swarmAccelerationPrefsKey))
        self.swarmRespawnRadiusSlider.doubleValue = (saverDefaults.double(forKey:Prefs.swarmRespawnRadiusPrefsKey))
        self.fadeSlider.doubleValue = (saverDefaults.double(forKey: Prefs.fadePrefsKey))
        // sync colour well enabled
        queenColorWell.isEnabled = queenVisibleCheckbox.state == NSControl.StateValue.on ? true : false
        swarmColorWell.isEnabled = swarmRainbowCheckbox.state == NSControl.StateValue.off ? true : false
    }
    
    // sync defaults from UI
    @IBAction func onOk(_ sender: Any) {
        saverDefaults.set(queenNumberSlider.integerValue, forKey: Prefs.queenNumberPrefsKey)
        saverDefaults.set(swarmNumberSlider.integerValue, forKey: Prefs.swarmNumberPrefsKey)
        saverDefaults.set(queenSpeedSlider.doubleValue, forKey: Prefs.queenSpeedPrefsKey)
        saverDefaults.set(swarmSpeedSlider.doubleValue, forKey: Prefs.swarmSpeedPrefsKey)
        saverDefaults.set(swarmAccelerationSlider.doubleValue, forKey: Prefs.swarmAccelerationPrefsKey)
        saverDefaults.set(swarmRespawnRadiusSlider.doubleValue, forKey: Prefs.swarmRespawnRadiusPrefsKey)
        saverDefaults.set(fadeSlider.doubleValue, forKey: Prefs.fadePrefsKey)
        saverDefaults.set([swarmColorWell.color.redComponent.native, swarmColorWell.color.greenComponent.native, swarmColorWell.color.blueComponent.native], forKey: Prefs.swarmColourPrefsKey)
        saverDefaults.set([queenColorWell.color.redComponent.native, queenColorWell.color.greenComponent.native, queenColorWell.color.blueComponent.native], forKey: Prefs.queenColourPrefsKey)
        saverDefaults.set(queenVisibleCheckbox.state == NSControl.StateValue.on ? true : false, forKey: Prefs.queenVisiblePrefsKey)
        saverDefaults.set(swarmRainbowCheckbox.state == NSControl.StateValue.on ? true : false, forKey: Prefs.swarmRainbowPrefsKey)
        
        // needed to close colour panel
        NSColorPanel.shared.orderOut(self)
        saverDefaults.synchronize()
        NSLog("on ok saver defaults %@", saverDefaults)
        syncPrefsToFields()
        // TODO need to let view know that number of bees changed? otherwise preview is incorrect
        sheet.endSheet(sheet)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        sheet.endSheet(sheet)
    }
    
    @IBAction func onQueenVisibleToggle(_ sender: Any) {
        queenColorWell.isEnabled = queenVisibleCheckbox.state == NSControl.StateValue.on ? true : false
        onAnyChanged(sender)
    }
    
    @IBAction func onSwarmRainbowToggle(_ sender: Any) {
        swarmColorWell.isEnabled = swarmRainbowCheckbox.state == NSControl.StateValue.off ? true : false
        onAnyChanged(sender)
    }

    @IBAction func onPresetChanged(_ sender: Any) {
        if let presetName = presetsComboBox.selectedItem?.title {
            if let preset = PrefsPresets.presets[presetName] {
                for k in preset.keys {
                    saverDefaults.set(preset[k], forKey: k)
                }
                configureSheet()
            }
        }
    }

    @IBAction func onAnyChanged(_ sender: Any) {
        presetsComboBox.selectItem(at: 0)
    }
    
    
}

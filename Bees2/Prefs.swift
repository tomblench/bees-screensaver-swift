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

public class Prefs : NSObject, NSControlTextEditingDelegate {
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
    
    @IBOutlet weak var myDel: MyDelegate!
    
    public override init() {
        // TODO update defaults for all keys
        /*
         Saver defaults <Screenprefs.saverDefaults: 0x133e265f0>
         {
         fade = "0.06514469844357977";
         queenColour =     (
         1,
         1,
         1,
         1
         );
         queenNumber = 10;
         queenSpeed = "45.62776820866141";
         swarmAcceleration = "0.00500738188976378";
         swarmColour =     (
         "0.5",
         "0.6182755878741468",
         1
         );
         swarmNumber = 1000;
         swarmRespawnRadius = 20;
         swarmSpeed = "15.33126230314961";
         }
         */
        let defaults = [Prefs.queenNumberPrefsKey:1,
                        Prefs.swarmNumberPrefsKey:10,
                        Prefs.queenSpeedPrefsKey:5.710116731517509,
                        Prefs.swarmSpeedPrefsKey:3.162086575875486,
                        Prefs.swarmRespawnRadiusPrefsKey:0.2740454766536965,
                        Prefs.swarmAccelerationPrefsKey:0.008631748540856032,
                        Prefs.fadePrefsKey:0.06514469844357977,
                        Prefs.swarmColourPrefsKey:[0.0,0.0,1.0],
                        Prefs.queenColourPrefsKey:[1.0,0.4153324174586498,0.790315105986194,1.0]] as [String : Any]
        NSLog("Saver defaults %@", saverDefaults ?? "nil")
        saverDefaults.register(defaults: defaults)
    }
    
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
        
        if let queenNumber = (queenNumberSlider.formatter as! NumberFormatter).number(from: queenNumberSlider.stringValue) {
            saverDefaults.set(queenNumber, forKey: Prefs.queenNumberPrefsKey)

        }
        if let swarmNumber = (swarmNumberSlider.formatter as! NumberFormatter).number(from: swarmNumberSlider.stringValue) {
            saverDefaults.set(swarmNumber, forKey: Prefs.swarmNumberPrefsKey)
        }
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
    
    @IBAction func onCancel(_ sender: Any) {
        NSApp.endSheet(prefsWindow!)
    }
    
    @IBAction func onQueenVisibleToggle(_ sender: Any) {
        queenColorWell.isEnabled = queenVisibleCheckbox.state == NSControl.StateValue.on ? true : false
    }

    @IBAction func onSwarmRainbowToggle(_ sender: Any) {
        swarmColorWell.isEnabled = swarmRainbowCheckbox.state == NSControl.StateValue.on ? true : false
    }
    

    // should use this instead? will it give live updates without focus change?
    public func control(_ control: NSControl, didFailToValidatePartialString string: String, errorDescription error: String?) {
        NSLog("*** didFailToValidatePartialString")
    }

    /*
    public func control(_ control: NSControl, isValidObject obj: Any?) -> Bool {
        
    }*/

    public func control(_ control: NSControl, didFailToFormatString string: String, errorDescription error: String?) -> Bool
    {
        NSLog("*** didFailToFormatString")
        
        if let textField = control as? NSTextField {
            // TODO return to previous value and return true
            if (textField == queenNumberSlider) {
                textField.integerValue = saverDefaults.integer(forKey: Prefs.queenNumberPrefsKey)
                return true;
            } else if (textField == swarmNumberSlider) {
                textField.integerValue = saverDefaults.integer(forKey: Prefs.swarmNumberPrefsKey)
                return true;
            }
            if let formatter = control.formatter as? NumberFormatter {
                NSLog("*** fiekd %@ %@ %@", textField.debugDescription, string, formatter.maximum ?? "???")
                
            }
        }
        NSLog("*** fail %@ %@ %@", control.debugDescription, string, error?.debugDescription ?? "???")
        return false;

    }

    /*
    func controlTextDidBeginEditing(_ obj: Notification) {
        
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        
    }

    func controlTextDidChange(_ obj: Notification) {
        
    }*/

    
}

//
//  PrefsPresets.swift
//  Bees2
//
//  Created by Thomas Blench on 23/10/2022.
//  Copyright © 2022 Thomas Blench. All rights reserved.
//

import Foundation

public class PrefsPresets {
    
    static let lonelyDrone =
    [Prefs.queenNumberPrefsKey: 10,
     Prefs.queenColourPrefsKey: [0, 0, 0],
     Prefs.queenVisiblePrefsKey: false,
     Prefs.queenSpeedPrefsKey: 23.0,
     Prefs.swarmNumberPrefsKey: 1,
     Prefs.swarmColourPrefsKey: [0, 0, 0],
     Prefs.swarmRainbowPrefsKey: true,
     Prefs.swarmSpeedPrefsKey: 100,
     Prefs.swarmAccelerationPrefsKey: 0.0059,
     Prefs.swarmRespawnRadiusPrefsKey: 1.77,
     Prefs.fadePrefsKey: 0.1] as [String : Any]
    
    static let greenPhosphorFireflies =
    [Prefs.queenNumberPrefsKey: 2,
     Prefs.queenColourPrefsKey: [0, 0, 0],
     Prefs.queenVisiblePrefsKey: false,
     Prefs.queenSpeedPrefsKey: 52.0,
     Prefs.swarmNumberPrefsKey: 122,
     Prefs.swarmColourPrefsKey: [0, 1, 0.064],
     Prefs.swarmRainbowPrefsKey: false,
     Prefs.swarmSpeedPrefsKey: 6.47,
     Prefs.swarmAccelerationPrefsKey: 0.001,
     Prefs.swarmRespawnRadiusPrefsKey: 1.77,
     Prefs.fadePrefsKey: 5.48] as [String : Any]
    
    static let sodiumGraffiti =
    [Prefs.queenNumberPrefsKey: 6,
     Prefs.queenColourPrefsKey: [0, 0, 0],
     Prefs.queenVisiblePrefsKey: false,
     Prefs.queenSpeedPrefsKey: 54.1,
     Prefs.swarmNumberPrefsKey: 1000,
     Prefs.swarmColourPrefsKey: [0, 0, 0],
     Prefs.swarmRainbowPrefsKey: true,
     Prefs.swarmSpeedPrefsKey: 20.9,
     Prefs.swarmAccelerationPrefsKey: 0.05,
     Prefs.swarmRespawnRadiusPrefsKey: 4.52,
     Prefs.fadePrefsKey: 0.1] as [String : Any]

    static let rainbowCloudConfetti =
    [Prefs.queenNumberPrefsKey: 10,
     Prefs.queenColourPrefsKey: [1, 0.14, 0],
     Prefs.queenVisiblePrefsKey: true,
     Prefs.queenSpeedPrefsKey: 20.0,
     Prefs.swarmNumberPrefsKey: 1000,
     Prefs.swarmColourPrefsKey: [0, 0, 0],
     Prefs.swarmRainbowPrefsKey: true,
     Prefs.swarmSpeedPrefsKey: 6.47,
     Prefs.swarmAccelerationPrefsKey: 0.001,
     Prefs.swarmRespawnRadiusPrefsKey: 1.77,
     Prefs.fadePrefsKey: 6.75] as [String : Any]

    
    static let presets = ["Lonely Drone": PrefsPresets.lonelyDrone,
                          "Green Phosphor Firefiles": PrefsPresets.greenPhosphorFireflies,
                          "Sodium Graffiti": PrefsPresets.sodiumGraffiti,
                          "Rainbow Cloud Confetti": rainbowCloudConfetti] as [String: [String : Any]]
    
}



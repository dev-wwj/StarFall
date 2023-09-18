//
//  SoundEffect.swift
//  StarFall
//
//  Created by wangwenjian on 2023/8/14.
//

import Foundation
import AudioToolbox
import AVFoundation

struct AudioEffect {
    
    struct Sound {
        var name: SoundName
        var id: SystemSoundID = 0
    }
        
    static var sounds: [Sound] = []
    
    enum SoundName: String {
        case broken = "broken"
    }
    
    static func play(_ name: SoundName, _extension: String = "mp3") {
        if var isOff = UserDefaults.standard.bool(forKey: "SoundOnOff") as? Bool, isOff == true {
            return
        }
        guard let sound = AudioEffect.sounds.first(where: { s in
            s.name == name
        }) else {
            initSound(name, _extension: _extension)
            return
        }
        AudioServicesPlaySystemSound(sound.id)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

    }
    
    static func initSound(_ name: SoundName, _extension: String) {
        guard let file = Bundle.main.url(forResource: name.rawValue, withExtension: _extension) else {
            assertionFailure("sound file not found")
            return
        }
        var soundId: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(file as CFURL, &soundId)
        AudioEffect.sounds.append(Sound(name: name,id: soundId))
        play(name, _extension: _extension)
    }
    

}

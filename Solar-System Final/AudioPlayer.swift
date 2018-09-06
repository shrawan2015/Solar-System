//
//  AudioPlayer.swift
//  ARDemo
//
//  Created by Puja Kumari on 30/08/18.
//  Copyright © 2018 Puja Kumari. All rights reserved.


import Foundation
import SceneKit

class AudioPlayer {
    
    enum Sound {
        case Mercury
        case Venus
        case Earth
        case Mars
        case Jupiter
        case Saturn
        case Uranus
        case Neptune
        case Pluto
    }
    var mp3FileName:[String] = ["art.scnassets/sounds/Mercury.mp3","art.scnassets/sounds/Venus.mp3","art.scnassets/sounds/Earth.mp3","art.scnassets/sounds/Mars.mp3","art.scnassets/sounds/success.wav","art.scnassets/sounds/fail.mp3","art.scnassets/sounds/Mercury.mp3","art.scnassets/sounds/Mercury.mp3","art.scnassets/sounds/Mercury.mp3"]
    
    static let shared = AudioPlayer()
    
    func audioSource(i:Int) -> SCNAudioSource {
        let sound = SCNAudioSource(fileNamed: mp3FileName[i])!
        sound.volume = 1
        sound.isPositional = true
        sound.shouldStream = false
        sound.load()
        return sound
    }
    
 
    
    private init() {}
    
    func playSound(_ sound: Sound, on node: SCNNode) {
        let action = SCNAction.playAudio(audioSourceForSound(sound),
                                         waitForCompletion: false)
        node.runAction(action)
    }
    
    private func audioSourceForSound(_ sound: Sound) -> SCNAudioSource {
        switch sound {
        case .Mercury:
            return audioSource(i: 0)
        case .Venus:
            return audioSource(i: 1)
        case .Earth:
            return audioSource(i: 2)
        case .Mars:
            return audioSource(i: 3)
        case .Jupiter:
            return audioSource(i: 4)
        case .Saturn:
            return audioSource(i: 5)
        case .Uranus:
            return audioSource(i: 6)
        case .Neptune:
            return audioSource(i: 7)
        case .Pluto:
            return audioSource(i: 8)
        }
    }
}

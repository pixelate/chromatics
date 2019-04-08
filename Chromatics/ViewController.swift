//
//  ViewController.swift
//  Chromatics
//
//  Created by Andreas Zecher
//

import AudioKit
import Cocoa

class ViewController: NSViewController {
    var oscillator = AKOscillator()
    var mixer = AKMixer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mixer = AKMixer(oscillator)
        AudioKit.output = mixer
        do {
            try AudioKit.start()
        } catch {
        }
        
        oscillator.amplitude = 1
        oscillator.stop()
        oscillator.frequency = [220, 440, 880].randomElement()!
        oscillator.start()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            self.keyDown(with: event)
            return nil
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 49 {
            oscillator.frequency = [220, 440, 880].randomElement()!
            oscillator.start()
        }
    }
}

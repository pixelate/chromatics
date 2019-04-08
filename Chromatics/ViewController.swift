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
    
    var currentHalfstep: Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mixer = AKMixer(oscillator)
        AudioKit.output = mixer
        do {
            try AudioKit.start()
        } catch {
        }
        
        oscillator.amplitude = 1
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            self.keyDown(with: event)
            return nil
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 49 {
            oscillator.frequency = Double(calculateFrequency(halfstep: currentHalfstep).description)!
            oscillator.start()

            currentHalfstep = currentHalfstep + 1
        }
    }
    
    func calculateFrequency(halfstep: Int) -> Decimal {
        let frequencyA4: Decimal = 440.0
        let twelfthRootOfTwo: Double = pow(2,(1/12))
        
        return frequencyA4 * pow(Decimal(twelfthRootOfTwo), halfstep)
    }
}

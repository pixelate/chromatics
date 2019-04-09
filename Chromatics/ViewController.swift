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
    
    let keyMappings: [UInt16: Note] = [
         6: Note.C,
         1: Note.CSharp,
         7: Note.D,
         2: Note.DSharp,
         8: Note.E,
         9: Note.F,
         5: Note.FSharp,
        11: Note.G,
         4: Note.GSharp,
        45: Note.A,
        38: Note.ASharp,
        46: Note.B
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mixer = AKMixer(oscillator)
        AudioKit.output = mixer
        do {
            try AudioKit.start()
        } catch {
        }
        
        oscillator.start()
        oscillator.amplitude = 1
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            self.keyDown(with: event)
            return nil
        }
    }

    override func viewDidDisappear() {
        super.viewWillDisappear()
        
        oscillator.stop()
    }
    
    override func keyDown(with event: NSEvent) {
        if let note = keyMappings[event.keyCode] {
            playNote(note)
        }
    }
    
    func playNote(_ note: Note) {
        oscillator.frequency = Double(frequencyForNote(note: note).description)!
    }
    
    func frequencyForNote(note: Note, octave: Int = 4) -> Decimal {
        return calculateFrequency(halfstep: note.rawValue)
    }
    
    func calculateFrequency(halfstep: Int) -> Decimal {
        let frequencyA4: Decimal = 440.0
        let twelfthRootOfTwo: Double = pow(2,(1/12))
        
        return frequencyA4 * pow(Decimal(twelfthRootOfTwo), halfstep)
    }
}

enum Note: Int {
    case C = 3
    case CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B
}

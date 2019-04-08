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
        
        oscillator.start()
        oscillator.amplitude = 1
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            self.keyDown(with: event)
            return nil
        }
    }
    
    override func keyDown(with event: NSEvent) {
        print(event.keyCode)

        if event.keyCode == 6 {
            playNote(Note.C)
        }

        if event.keyCode == 1 {
            playNote(Note.CSharp)
        }

        if event.keyCode == 7 {
            playNote(Note.D)
        }

        if event.keyCode == 2 {
            playNote(Note.DSharp)
        }

        if event.keyCode == 8 {
            playNote(Note.E)
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

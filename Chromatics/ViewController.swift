//
//  ViewController.swift
//  Chromatics
//
//  Created by Andreas Zecher
//

import AudioKit
import Cocoa

class ViewController: NSViewController {
    var oscillator: AKOscillator = AKOscillator()
    var mixer: AKMixer = AKMixer()
    
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
        
        setupAudio()
        
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
    
    func setupAudio() {
        oscillator = AKOscillator(waveform: AKTable(.triangle))
        mixer = AKMixer(oscillator)
        AudioKit.output = mixer
        do {
            try AudioKit.start()
        } catch {
        }
        
        oscillator.start()
        oscillator.amplitude = 1
    }
    
    func playNote(_ note: Note) {
        oscillator.frequency = Double(frequencyForNote(note: note).description)!
    }
    
    func frequencyForNote(note: Note, octave: Int = 4) -> Decimal {
        let octaveOffset: Int = (octave - 4) * 12
        return calculateFrequency(halfstep: note.rawValue + octaveOffset)
    }

    // See https://pages.mtu.edu/~suits/NoteFreqCalcs.html
    func calculateFrequency(halfstep: Int) -> Decimal {
        let frequencyA4: Decimal = 440.0
        let twelfthRootOfTwo: Double = pow(2,(1/12))
        
        if(halfstep < 0) {
            return frequencyA4 / pow(Decimal(twelfthRootOfTwo), -halfstep)
        }
        else {
            return frequencyA4 * pow(Decimal(twelfthRootOfTwo), halfstep)
        }
    }
}

enum Note: Int {
    case C = 3
    case CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B
}

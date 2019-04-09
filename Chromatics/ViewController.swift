//
//  ViewController.swift
//  Chromatics
//
//  Created by Andreas Zecher
//

import AudioKit
import Cocoa

struct Constants {
    static let frequencyA4: Decimal = 440.0
    static let twelfthRootOfTwo: Double = pow(2,(1/12))
    static let baseOctave: Int = 4
    static let halfstepsInOctave: Int = 12
}

enum Note: Int {
    case C = 3
    case CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B
}

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
    
    func frequencyForNote(note: Note, octave: Int = Constants.baseOctave) -> Decimal {
        let octaveOffset: Int = (octave - Constants.baseOctave) * Constants.halfstepsInOctave
        return calculateFrequency(halfsteps: note.rawValue + octaveOffset)
    }

    // See https://pages.mtu.edu/~suits/NoteFreqCalcs.html
    func calculateFrequency(halfsteps: Int) -> Decimal {
        if(halfsteps < 0) {
            return Constants.frequencyA4 / pow(Decimal(Constants.twelfthRootOfTwo), -halfsteps)
        }
        else {
            return Constants.frequencyA4 * pow(Decimal(Constants.twelfthRootOfTwo), halfsteps)
        }
    }
}


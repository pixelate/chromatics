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
    var oscillators: [Note: AKOscillator] = [
        Note.C:      AKOscillator(waveform: AKTable(.triangle)),
        Note.CSharp: AKOscillator(waveform: AKTable(.triangle)),
        Note.D:      AKOscillator(waveform: AKTable(.triangle)),
        Note.DSharp: AKOscillator(waveform: AKTable(.triangle)),
        Note.E:      AKOscillator(waveform: AKTable(.triangle)),
        Note.F:      AKOscillator(waveform: AKTable(.triangle)),
        Note.FSharp: AKOscillator(waveform: AKTable(.triangle)),
        Note.G:      AKOscillator(waveform: AKTable(.triangle)),
        Note.GSharp: AKOscillator(waveform: AKTable(.triangle)),
        Note.A:      AKOscillator(waveform: AKTable(.triangle)),
        Note.ASharp: AKOscillator(waveform: AKTable(.triangle)),
        Note.B:      AKOscillator(waveform: AKTable(.triangle))
    ]
    
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

        NSEvent.addLocalMonitorForEvents(matching: .keyUp) { (event) -> NSEvent? in
            self.keyUp(with: event)
            return nil
        }
    }

    override func viewDidDisappear() {
        super.viewWillDisappear()
    }
    
    override func keyDown(with event: NSEvent) {
        if let note = keyMappings[event.keyCode] {
            playNote(note)
        }
    }

    override func keyUp(with event: NSEvent) {
        if let note = keyMappings[event.keyCode] {
            if let oscillator = oscillators[note] {
                oscillator.stop()
            }
        }
    }

    func setupAudio() {
        mixer = AKMixer()
        
        for(_, oscillator) in oscillators {
            mixer.connect(input: oscillator)
        }
        
        AudioKit.output = mixer
        do {
            try AudioKit.start()
        } catch {
        }
    }
    
    func playNote(_ note: Note) {
        if let oscillator = oscillators[note] {
            oscillator.frequency = Double(frequencyForNote(note: note).description)!
            oscillator.start()
        }
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


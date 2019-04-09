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
    static let minOctave: Int = 1
    static let maxOctave: Int = 5
    static let halfstepsInOctave: Int = 12
}

enum Note: Int, CaseIterable {
    case C = 3
    case CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B
}

class ViewController: NSViewController {
    var oscillators: [UInt16: AKOscillator] = [:]

    var mixer: AKMixer = AKMixer()
    
    var octaveModifier: Int = 0
    
    let keyMappings: [UInt16: (Note, Int)] = [
        6:  (note: Note.C, octave: 4),
        1:  (note: Note.CSharp, octave: 4),
        7:  (note: Note.D, octave: 4),
        2:  (note: Note.DSharp, octave: 4),
        8:  (note: Note.E, octave: 4),
        9:  (note: Note.F, octave: 4),
        5:  (note: Note.FSharp, octave: 4),
        11: (note: Note.G, octave: 4),
        4:  (note: Note.GSharp, octave: 4),
        45: (note: Note.A, octave: 4),
        38: (note: Note.ASharp, octave: 4),
        46: (note: Note.B, octave: 4),
        43: (note: Note.C, octave: 5)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudio()
        setupEventHandlers()
    }

    override func keyDown(with event: NSEvent) {
        if let (note, octave) = keyMappings[event.keyCode] {
            if let oscillator = oscillators[event.keyCode] {
                oscillator.frequency = Double(frequencyForNote(
                    note: note,
                    octave: octave + octaveModifier
                ).description)!
                oscillator.start()
            }
        }
        
        if(event.keyCode == 47) {
            octaveModifier = max(
                Constants.minOctave - Constants.baseOctave,
                octaveModifier - 1
            )
        }

        if(event.keyCode == 44) {
            octaveModifier = min(
                Constants.maxOctave - Constants.baseOctave,
                octaveModifier + 1
            )
        }
    }

    override func keyUp(with event: NSEvent) {
        if keyMappings[event.keyCode] != nil {
            if let oscillator = oscillators[event.keyCode] {
                oscillator.stop()
            }
        }
    }

    func setupAudio() {
        mixer = AKMixer()

        for (key, value) in keyMappings {
            let (note, octave) = value
            oscillators[key] = AKOscillator(
                waveform: AKTable(.triangle),
                frequency: Double(frequencyForNote(note: note, octave: octave).description)!
            )
            
            oscillators[key]!.rampDuration = 0
            mixer.connect(input: oscillators[key])
        }

        AudioKit.output = mixer
        do { try AudioKit.start() } catch {}
    }
    
    func setupEventHandlers() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            self.keyDown(with: event)
            return nil
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyUp) { (event) -> NSEvent? in
            self.keyUp(with: event)
            return nil
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


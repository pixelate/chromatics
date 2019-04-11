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
    static let minOctave: Int = 2
    static let maxOctave: Int = 6
    static let halfstepsInOctave: Int = 12
}

enum Note: Int {
    case C = -9 // C4 is 9 halfsteps below A4
    case CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B
}

class ViewController: NSViewController {
    @IBOutlet weak var buttonKeyZ: MusicalKeyButton!
    @IBOutlet weak var buttonKeyX: MusicalKeyButton!
    @IBOutlet weak var buttonKeyC: MusicalKeyButton!
    @IBOutlet weak var buttonKeyV: MusicalKeyButton!
    @IBOutlet weak var buttonKeyB: MusicalKeyButton!
    @IBOutlet weak var buttonKeyN: MusicalKeyButton!
    @IBOutlet weak var buttonKeyM: MusicalKeyButton!
    @IBOutlet weak var buttonKeySemicolon: MusicalKeyButton!
    @IBOutlet weak var buttonKeyS: MusicalKeyButton!
    @IBOutlet weak var buttonKeyD: MusicalKeyButton!
    @IBOutlet weak var buttonKeyG: MusicalKeyButton!
    @IBOutlet weak var buttonKeyH: MusicalKeyButton!
    @IBOutlet weak var buttonKeyJ: MusicalKeyButton!
    
    @IBAction func buttonKeyAction(_ button: MusicalKeyButton) {
        if(button.state == NSControl.StateValue.on) {
            playNoteForKeyCode(button.keyCode)
        }
        else {
            stopNoteForKeyCode(button.keyCode)
        }
    }

    var buttonCollection: [MusicalKeyButton] = []
    
    var oscillators: [UInt16: AKOscillator] = [:]

    var mixer: AKMixer?
    
    var envelopes: [UInt16: AKAmplitudeEnvelope] = [:]

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
    
    func setupButtonCollection() {
        buttonCollection = [
            buttonKeyZ,
            buttonKeyX,
            buttonKeyC,
            buttonKeyV,
            buttonKeyB,
            buttonKeyN,
            buttonKeyM,
            buttonKeySemicolon,
            buttonKeyS,
            buttonKeyD,
            buttonKeyG,
            buttonKeyH,
            buttonKeyJ
        ]
    }

    func findButtonByKeyCode(_ keyCode: UInt16) -> MusicalKeyButton? {
        for button in buttonCollection {
            if button.keyCode == keyCode {
                return button
            }
        }
        
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudio()
        setupEventHandlers()
        setupButtonCollection()
    }

    override func keyDown(with event: NSEvent) {
        playNoteForKeyCode(event.keyCode)
        
        if let button = findButtonByKeyCode(event.keyCode) {
            button.highlight(true)
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
        stopNoteForKeyCode(event.keyCode)
        
        if let button = findButtonByKeyCode(event.keyCode) {
            button.highlight(false)
            button.state = .off
        }
    }

    func setupAudio() {
        mixer = AKMixer()

        for (key, value) in keyMappings {
            let (note, octave) = value
            let oscillator = AKOscillator(
                waveform: AKTable(.triangle),
                frequency: Double(frequencyForNote(note: note, octave: octave).description)!
            )
            
            oscillator.rampDuration = 0
            envelopes[key] = AKAmplitudeEnvelope(oscillator)
            oscillators[key] = oscillator
        }
        
        mixer = AKMixer(Array(envelopes.values))
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

    func playNoteForKeyCode(_ keyCode: UInt16) {
        if let (note, octave) = keyMappings[keyCode] {
            if let oscillator = oscillators[keyCode] {
                oscillator.frequency = Double(frequencyForNote(
                    note: note,
                    octave: octave + octaveModifier
                    ).description)!
                oscillator.start()
            }
            
            if let envelope = envelopes[keyCode] {
                envelope.start()
            }
        }
    }
    
    func stopNoteForKeyCode(_ keyCode: UInt16) {
        if keyMappings[keyCode] != nil {
            if let envelope = envelopes[keyCode] {
                envelope.stop()
            }
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


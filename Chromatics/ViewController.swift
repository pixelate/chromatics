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

enum Note: Int {
    case C = 3
    case CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B
}

class ViewController: NSViewController {
    @IBOutlet weak var buttonKeyZ: NSButton!
    @IBOutlet weak var buttonKeyX: NSButton!
    @IBOutlet weak var buttonKeyC: NSButton!
    @IBOutlet weak var buttonKeyV: NSButton!
    @IBOutlet weak var buttonKeyB: NSButton!
    @IBOutlet weak var buttonKeyN: NSButton!
    @IBOutlet weak var buttonKeyM: NSButton!
    @IBOutlet weak var buttonKeySemicolon: NSButton!
    @IBOutlet weak var buttonKeyS: NSButton!
    @IBOutlet weak var buttonKeyD: NSButton!
    @IBOutlet weak var buttonKeyG: NSButton!
    @IBOutlet weak var buttonKeyH: NSButton!
    @IBOutlet weak var buttonKeyJ: NSButton!
    
    @IBAction func buttonKeyAction(_ button: MusicalKeyButton) {
        if(button.state == NSControl.StateValue.on) {
            playNoteForKeyCode(button.keyCode)
        }
        else {
            stopNoteForKeyCode(button.keyCode)
        }
    }
    
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
        playNoteForKeyCode(event.keyCode)
        highlightKey(event.keyCode, true)

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
        highlightKey(event.keyCode, false)
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

    func playNoteForKeyCode(_ keyCode: UInt16) {
        if let (note, octave) = keyMappings[keyCode] {
            if let oscillator = oscillators[keyCode] {
                oscillator.frequency = Double(frequencyForNote(
                    note: note,
                    octave: octave + octaveModifier
                    ).description)!
                oscillator.start()
            }
        }
    }
    
    func stopNoteForKeyCode(_ keyCode: UInt16) {
        if keyMappings[keyCode] != nil {
            if let oscillator = oscillators[keyCode] {
                oscillator.stop()
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
    
    func highlightKey(_ keycode: UInt16, _ shouldHighlight: Bool) {
        switch(keycode) {
        case 6:
            buttonKeyZ.highlight(shouldHighlight)
        case 7:
            buttonKeyX.highlight(shouldHighlight)
        case 8:
            buttonKeyC.highlight(shouldHighlight)
        case 9:
            buttonKeyV.highlight(shouldHighlight)
        case 11:
            buttonKeyB.highlight(shouldHighlight)
        case 45:
            buttonKeyN.highlight(shouldHighlight)
        case 46:
            buttonKeyM.highlight(shouldHighlight)
        case 43:
            buttonKeySemicolon.highlight(shouldHighlight)
        case 1:
            buttonKeyS.highlight(shouldHighlight)
        case 2:
            buttonKeyD.highlight(shouldHighlight)
        case 5:
            buttonKeyG.highlight(shouldHighlight)
        case 4:
            buttonKeyH.highlight(shouldHighlight)
        case 38:
            buttonKeyJ.highlight(shouldHighlight)
        default: ()
        }
    }
}


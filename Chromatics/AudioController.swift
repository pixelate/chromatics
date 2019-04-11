//
//  AudioController.swift
//  Chromatics
//
//  Created by Andreas Zecher
//

import Cocoa
import AudioKit

class AudioController: NSObject {

    let frequencyA4: Decimal = 440.0
    let twelfthRootOfTwo: Double = pow(2, (1/12))

    var mixer: AKMixer?
    var envelopes: [UInt16: AKAmplitudeEnvelope] = [:]
    var oscillators: [UInt16: AKOscillator] = [:]

    var octaveModifier: Int = 0

    let keyMappings: [UInt16: (Note, Int)] = [
        6: (note: Note.C, octave: 4),
        1: (note: Note.CSharp, octave: 4),
        7: (note: Note.D, octave: 4),
        2: (note: Note.DSharp, octave: 4),
        8: (note: Note.E, octave: 4),
        9: (note: Note.F, octave: 4),
        5: (note: Note.FSharp, octave: 4),
        11: (note: Note.G, octave: 4),
        4: (note: Note.GSharp, octave: 4),
        45: (note: Note.A, octave: 4),
        38: (note: Note.ASharp, octave: 4),
        46: (note: Note.B, octave: 4),
        43: (note: Note.C, octave: 5)
    ]

    func setup() {
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

    private func frequencyForNote(note: Note, octave: Int = Octave.base) -> Decimal {
        let octaveOffset: Int = (octave - Octave.base) * Octave.halfsteps
        return calculateFrequency(halfsteps: note.rawValue + octaveOffset)
    }

    // See https://pages.mtu.edu/~suits/NoteFreqCalcs.html
    private func calculateFrequency(halfsteps: Int) -> Decimal {
        if(halfsteps < 0) {
            return frequencyA4 / pow(Decimal(twelfthRootOfTwo), -halfsteps)
        } else {
            return frequencyA4 * pow(Decimal(twelfthRootOfTwo), halfsteps)
        }
    }
}

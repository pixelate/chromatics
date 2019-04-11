//
//  ViewController.swift
//  Chromatics
//
//  Created by Andreas Zecher
//

import AudioKit
import Cocoa

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
    @IBOutlet weak var octaveSegmentedControl: OctaveSegmentedControl!

    @IBAction func buttonKeyAction(_ button: MusicalKeyButton) {
        if(button.state == NSControl.StateValue.on) {
            audioController.playNoteForKeyCode(button.keyCode)
        } else {
            audioController.stopNoteForKeyCode(button.keyCode)
        }
    }

    @IBAction func octaveSegmentedControlAction(_ segmentedControl: OctaveSegmentedControl) {
        let octave = segmentedControl.selectedSegment + Octave.min
        audioController.octaveModifier = octave - Octave.base
    }

    var buttonCollection: [MusicalKeyButton] = []

    var audioController = AudioController()

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

    func findButtonBy(keyCode: UInt16) -> MusicalKeyButton? {
        return buttonCollection.first(where: { $0.keyCode == keyCode })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        audioController.setup()
        setupEventHandlers()
        setupButtonCollection()
    }

    override func keyDown(with event: NSEvent) {
        audioController.playNoteForKeyCode(event.keyCode)

        if let button = findButtonBy(keyCode: event.keyCode) {
            button.highlight(true)
        }

        if(event.keyCode == 19) {
            audioController.octaveModifier = -2
            octaveSegmentedControl.selectedSegment = 0
        } else if(event.keyCode == 20) {
            audioController.octaveModifier = -1
            octaveSegmentedControl.selectedSegment = 1
        } else if(event.keyCode == 21) {
            audioController.octaveModifier = 0
            octaveSegmentedControl.selectedSegment = 2
        } else if(event.keyCode == 23) {
            audioController.octaveModifier = 1
            octaveSegmentedControl.selectedSegment = 3
        }
    }

    override func keyUp(with event: NSEvent) {
        audioController.stopNoteForKeyCode(event.keyCode)

        if let button = findButtonBy(keyCode: event.keyCode) {
            button.highlight(false)
            button.state = .off
        }
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
}

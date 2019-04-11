//
//  MusicalKeyButton.swift
//  Chromatics
//
//  Created by Andreas Zecher
//

import Cocoa

@IBDesignable class MusicalKeyButton: NSButton {

    @IBInspectable var keyCode: UInt16 = 1 {
        didSet {
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sendAction(on: [.leftMouseDown, .leftMouseUp])
    }
}

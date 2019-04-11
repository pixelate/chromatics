//
//  OctaveSegmentedControl.swift
//  Chromatics
//
//  Created by Andreas Zecher
//

import Cocoa

class OctaveSegmentedControl: NSSegmentedControl {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.segmentCount = Octave.max - Octave.min + 1
        
        for n in 0 ..< self.segmentCount {
            self.setLabel(String(n + Octave.min), forSegment: n)
        }
        
        self.selectedSegment = Octave.base - Octave.min
    }

}

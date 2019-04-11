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
        
        self.segmentCount = Constants.maxOctave - Constants.minOctave + 1
        
        for n in 0 ..< self.segmentCount {
            self.setLabel(String(n + Constants.minOctave), forSegment: n)
        }
        
        self.selectedSegment = Constants.baseOctave - Constants.minOctave
    }

}

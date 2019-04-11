# Chromatics

A simple synthesizer for macOS with keyboard input based on [AudioKit](https://audiokit.io/) written in Swift 5. Created during Lab Week at [Mynewsdesk](https://www.mynewsdesk.com) in spring 2019.

## Build

Xcode 10.2 is required to build. Download [AudioKit.framework](https://github.com/AudioKit/AudioKit/releases/download/v4.7/AudioKit.framework.zip) and then change `FRAMEWORK_SEARCH_PATHS` in `project.pbxproj` to point to the directory where you saved `AudioKit.framework`.

## Play

<img src="screenshot.png" alt="Screenshot" width="592" height="506">

Press keys on keyboard as shown above to play musical notes. Click buttons to toggle musical notes.

Press keys 2 – 5 to change octave.

## Learnings

* Using [AudioKit](https://audiokit.io/) to create [oscillators](https://en.wikibooks.org/wiki/Sound_Synthesis_Theory/Oscillators_and_Wavetables#Oscillators_and_Wavetables) and [ADSR envelopes](https://en.wikipedia.org/wiki/Envelope_(music)#ADSR) for each musical key
* [Calculating frequency](https://pages.mtu.edu/~suits/NoteFreqCalcs.html) for a given musical note 
* Using [Enumerations](https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html#ID146), [Dictionaries](https://docs.swift.org/swift-book/LanguageGuide/CollectionTypes.html#ID113), [Tuples](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html#ID329) and [Structs](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html#ID83) in Swift
* Creating and connecting UI elements in Xcode with Storyboards using [@IBOutlet/@IBActions](https://www.raywenderlich.com/731-macos-development-for-beginners-part-1) and [@IBDesignable](https://medium.com/bpxl-craft/working-with-ibdesignable-e8318a2c3e55)

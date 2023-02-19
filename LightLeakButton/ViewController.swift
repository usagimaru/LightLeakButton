//
//  ViewController.swift
//  LightLeakButton
//
//  Created by usagimaru on 2023/02/14.
//

import Cocoa

class ViewController: NSViewController {
	
	@IBOutlet var button1: LightLeakButton!
	@IBOutlet var button2: LightLeakButton!
	@IBOutlet var button3: LightLeakButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let buttonColor = NSColor(calibratedWhite: 0.1, alpha: 1)
		
		self.view.wantsLayer = true
		self.view.layer?.backgroundColor = buttonColor.cgColor
		
		func setupButton(_ button: LightLeakButton, title: String) {
			button.cornerRadius = 20
			button.stringValue = title
			button.backgroundColor = buttonColor
		}
		
		setupButton(self.button1, title: "BUTTON")
		setupButton(self.button2, title: "墾田永年私財法")
		setupButton(self.button3, title: "生類憐れみの令 生類憐れみの令 生類憐れみの令")
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}


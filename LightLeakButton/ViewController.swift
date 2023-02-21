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
	@IBOutlet var button4: LightLeakButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		func setupButton(_ button: LightLeakButton, title: String) {
			button.cornerRadius = 20
			button.stringValue = title
		}
		
		setupButton(self.button1, title: "BUTTON")
		setupButton(self.button2, title: "ボタン")
		setupButton(self.button3, title: "押す")
		self.button3.toolTip = "This is a light leak button."
		setupButton(self.button4, title: "PUSH")
		
		// Background color
		self.view.wantsLayer = true
		self.view.layer?.backgroundColor = self.button1.backgroundColor.cgColor
	}

}


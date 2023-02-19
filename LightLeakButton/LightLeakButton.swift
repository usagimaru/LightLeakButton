//
//  LightLeakButton.swift
//  LightLeakButton
//
//  Created by usagimaru on 2023/02/14.
//

import Cocoa
import CAAnimationCallback

class LightLeakButton: NSControl {
	
	/// Title
	override var stringValue: String { didSet {
		if self.labelLayer.isTextWrapped() {
			super.toolTip = stringValue
		}
		else {
			super.toolTip = _toolTip
		}
		
		self.needsLayout = true
		self.needsDisplay = true
	}}
	
	/// Title typeface and size
	override var font: NSFont? { didSet {
		self.needsDisplay = true
	}}
	
	/// Title horizontal alignment
	override var alignment: NSTextAlignment { didSet {
		self.needsDisplay = true
	}}
	
	/// Title truncation
	var labelTruncationMode: CATextLayerTruncationMode = .end { didSet {
		self.needsDisplay = true
	}}
	
	/// Corner radius
	var cornerRadius: CGFloat = 0 { didSet {
		self.needsLayout = true
	}}
	
	override var isHighlighted: Bool { didSet {
		self.needsDisplay = true
	}}
	
	private var _toolTip: String?
	override var toolTip: String? { didSet {
		_toolTip = toolTip
	}}
	
	override var wantsUpdateLayer: Bool {
		true
	}
		
	var mainLayer: CALayer {
		self.layer!
	}
	
	var grooveWidth: CGFloat = 4 { didSet {
		self.needsLayout = true
		self.needsDisplay = true
	}}
	
	var backgroundColor: NSColor = .black { didSet {
		self.needsDisplay = true
	}}
	
	private var isGradientLoopAnimating = false
	private var boundsLayer = CALayer()
	private var innerContentLayer = CALayer()
	private var labelBackLayer = CALayer()
	private var labelLayer = HollowingTextLayer()
	private var glowLayer1 = CAGradientLayer()
	private var glowLayer2 = CAGradientLayer()
	private var glowLayer_highlighted = CAGradientLayer()
	private var haloLayer = CAGradientLayer()
	
	
	// MARK: -
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		_init()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		_init()
	}
	
	override var intrinsicContentSize: NSSize {
		let superSize = super.intrinsicContentSize
		
		layout()
		
		return NSSize {
			self.labelLayer.calculateTextBounds().width + self.grooveWidth * 2
		} h: {
			self.labelLayer.calculateTextBounds().height + self.grooveWidth * 2
		}

	}
	
	private func _init() {
		self.wantsLayer = true
		self.layerContentsRedrawPolicy = .duringViewResize
		
		self.font = NSFont.systemFont(ofSize: 30, weight: .bold)
		self.alignment = .center
		
		CALayer.disableAnimations {
			self.mainLayer.masksToBounds = false
			self.boundsLayer.masksToBounds = true
			
			self.mainLayer.addSublayer(self.boundsLayer)
			self.boundsLayer.addSublayer(self.glowLayer1)
			self.boundsLayer.addSublayer(self.glowLayer2)
			self.boundsLayer.addSublayer(self.glowLayer_highlighted)
			self.boundsLayer.addSublayer(self.innerContentLayer)
			self.boundsLayer.addSublayer(self.labelBackLayer)
			self.boundsLayer.addSublayer(self.labelLayer)
			self.mainLayer.addSublayer(self.haloLayer)
			
			self.glowLayer1.opacity = 0.0
			self.glowLayer2.opacity = 0.0
			
			resetTrackingArea()
#if DEBUG
			//self.boundsLayer.setBorderColor(NSColor.gray.cgColor)
			//self.labelLayer.setBorderColor(NSColor.red.cgColor)
			//self.glowLayer1.setBorderColor(NSColor.red.cgColor)
			//self.haloLayer.setBorderColor(NSColor.blue.cgColor)
			//self.innerContentLayer.setBorderColor(NSColor.purple.cgColor)
#endif
		}
		
		self.needsLayout = true
		self.needsDisplay = true
	}
	
	private func setupGradientLoopAnimation(_ type: GradientLoopColorType = .typeA) {
		if !self.isGradientLoopAnimating {
			self.glowLayer1.removeAnimation(forKey: "gradientLoop")
			return
		}
		
		let gradientAnim = CABasicAnimation(keyPath: "colors")
		gradientAnim.duration = 2.5
		gradientAnim.fillMode = CAMediaTimingFillMode.forwards
		gradientAnim.isRemovedOnCompletion = false
		gradientAnim.fromValue = type.gradientColors()
		gradientAnim.toValue = type.nextType().gradientColors()
		
		gradientAnim.completionHandler { [weak self] anim, flag in
			self?.setupGradientLoopAnimation(type.nextType())
		}
		
		self.glowLayer1.add(gradientAnim, forKey: "gradientLoop")
	}
	
	
	// MARK: -
	
	private func updateGradientLayer(_ layer: CAGradientLayer, animate: Bool, blendMode: CGBlendMode = .normal) {
		layer.type = .radial
		layer.startPoint = NSPoint(x: 0.5, y: 0.5)
		layer.endPoint = NSPoint(x: 1.0, y: 1.0)
		layer.colors = GradientLoopColorType.typeA.gradientColors()
		
		if !self.isGradientLoopAnimating && animate {
			self.isGradientLoopAnimating = true
			setupGradientLoopAnimation()
		}
		
//		// 1 Normal, 1.25x width, 0.75x height
//		NSColor(deviceHue: 0.825, saturation: 0.85, brightness: 1.0, alpha: 1)
//		NSColor(deviceHue: 0.75, saturation: 0.90, brightness: 1.0, alpha: 1)
//		NSColor(deviceHue: 0.55, saturation: 0.93, brightness: 1.0, alpha: 1)
//
//		// 2 Color Dodge, 1.25x width, 0.75x height
//		NSColor(deviceHue: 0.70, saturation: 0.46, brightness: 1.0, alpha: 1)
//
//		// 3 Hard Light, 4x width, 2.4x height
//		NSColor(deviceHue: 0.53, saturation: 0.44, brightness: 0.98, alpha: 1)
	}
	
	private func updateTextLabelLayer() {
		self.labelLayer.string = self.stringValue
		self.labelLayer.font = self.font
		self.labelLayer.fontSize = self.font?.pointSize ?? 0
		self.labelLayer.truncationMode = self.labelTruncationMode
		self.labelLayer.alignmentMode = self.alignment.layerAlignmentMode()
	}
	
	override func updateLayer() {
		CALayer.disableAnimations {
			//self.innerContentLayer.backgroundColor = NSColor.darkGray.cgColor
			//self.labelBackLayer.backgroundColor = NSColor.darkGray.cgColor
			self.boundsLayer.backgroundColor = NSColor.black.cgColor
			
			// Text Layer
			self.labelLayer.contentsScale = self.window?.backingScaleFactor ?? 1.0
			self.labelLayer.foregroundColor = nil
			self.labelLayer.isWrapped = false
			self.labelLayer.masksToBounds = true
			self.labelLayer.backgroundFillColor = self.backgroundColor.cgColor
			self.labelLayer.isHollowing = true
			self.labelLayer.backgroundDrawing = nil
			updateTextLabelLayer()
			
//			self.labelLayer.setBorderColor(NSColor.green.cgColor)
			
			// Glow Layer 1 (animating)
			self.glowLayer1.type = .radial
			self.glowLayer1.startPoint = NSPoint(0.5, 0.5)
			self.glowLayer1.endPoint = NSPoint(1.0, 1.0)
			self.glowLayer1.colors = GradientLoopColorType.typeA.gradientColors()
			self.glowLayer1.compositingFilter = "normalBlendMode"
			
			// Glow Layer 2
			self.glowLayer2.type = .radial
			self.glowLayer2.startPoint = NSPoint(0.5, 0.5)
			self.glowLayer2.endPoint = NSPoint(1.0, 1.0)
			let color2_1 = NSColor(deviceHue: 0.70, saturation: 0.46, brightness: 1.0, alpha: 1)
			self.glowLayer2.colors = [
				color2_1.cgColor,
				color2_1.withAlphaComponent(0).cgColor,
			]
			self.glowLayer2.compositingFilter = "colorDodgeBlendMode"
			
			// Glow Layer 3
			self.glowLayer_highlighted.type = .radial
			self.glowLayer_highlighted.startPoint = NSPoint(0.5, 0.5)
			self.glowLayer_highlighted.endPoint = NSPoint(1.0, 1.0)
			let color3_1 = NSColor(deviceHue: 0.53, saturation: 0.44, brightness: 0.98, alpha: 1)
			self.glowLayer_highlighted.colors = [
				color3_1.cgColor,
				color3_1.withAlphaComponent(0).cgColor,
			]
			self.glowLayer_highlighted.compositingFilter = "hardLightBlendMode"
		}
		
		// クリック時の見た目とアニメーション
		if self.isHighlighted {
			CALayer.animate(enabled: true, duration: 0.08) {
				self.glowLayer_highlighted.opacity = 1.0
			}
		}
		else {
			CALayer.animate(enabled: true, duration: 0.75) {
				self.glowLayer_highlighted.opacity = 0.0
			}
		}
		
		// ループアニメーション
		if !self.isGradientLoopAnimating {
			self.isGradientLoopAnimating = true
			setupGradientLoopAnimation()
		}
	}
	
	override func layout() {
		super.layout()
		
		CALayer.disableAnimations {
			self.boundsLayer.frame = self.bounds
			self.boundsLayer.setCornerRadius(self.cornerRadius)
			
			self.innerContentLayer.frame = self.bounds.insetBy(self.grooveWidth)
			let innerRadius = (self.cornerRadius > 0) ? self.cornerRadius - self.grooveWidth : 0
			self.innerContentLayer.setCornerRadius(innerRadius)
			
			self.labelBackLayer.frame = self.bounds.insetBy(self.grooveWidth)
			
			updateTextLabelLayer()
			let labelFrame = self.innerContentLayer.frame
			self.labelLayer.constraintSizeOfFitting = labelFrame.size
			//self.labelLayer.fittingSize()
			self.labelLayer.size = labelFrame.size
			
			self.labelLayer.origin = CGPoint(x: {
				(self.bounds.width - self.labelLayer.bounds.width) / 2
			},
											 y: {
				(self.bounds.height - self.labelLayer.bounds.height) / 2
			})
			
			self.labelLayer.setCornerRadius(innerRadius)
			
			
			// 1 1.25x width, 0.75x height
			let glowFrame = self.bounds.insetBy(dx: self.bounds.width - self.bounds.width * 1.25,
												 dy: self.bounds.width * 0.75 - self.bounds.width)
			self.glowLayer1.frame = glowFrame
			
			// 2 1.25x width, 0.75x height
			self.glowLayer2.frame = glowFrame
			
			// 3 4x width, 2.4x height
			let glowHighlightedFrame = self.bounds.insetBy(dx: self.bounds.width - self.bounds.width * 4.0,
														   dy: self.bounds.width - self.bounds.width * 2.4)
			self.glowLayer_highlighted.frame = glowHighlightedFrame
		}
	}
	
	
	// MARK: - Tracking Area
	
	private var trackingArea: NSTrackingArea?
	
//	override func updateTrackingAreas() {
//		super.updateTrackingAreas()
//	}
//
//	override func viewDidMoveToSuperview() {
//		resetTrackingArea()
//	}
//
//	override func viewDidEndLiveResize() {
//		super.viewDidEndLiveResize()
//		resetTrackingArea()
//	}
	
	private func resetTrackingArea() {
		if let trackingArea = self.trackingArea {
			removeTrackingArea(trackingArea)
		}
		
		let options: NSTrackingArea.Options = [
			.activeInKeyWindow,
			.mouseEnteredAndExited,
			.mouseMoved,
			.inVisibleRect,
			.enabledDuringMouseDrag,
		]
		let trackingArea = NSTrackingArea(rect: .zero,
										  options: options,
										  owner: self,
										  userInfo: nil)
		self.trackingArea = trackingArea
		addTrackingArea(trackingArea)
	}
	
	
	// MARK: -
	
	override func mouseDown(with event: NSEvent) {
		super.mouseDown(with: event)
		self.isHighlighted = true
	}
	
	override func mouseUp(with event: NSEvent) {
		super.mouseUp(with: event)
		self.isHighlighted = false
	}
	
	override func mouseMoved(with event: NSEvent) {
		super.mouseMoved(with: event)
		updateMouseLocation()
	}
	
	override func mouseEntered(with event: NSEvent) {
		super.mouseEntered(with: event)
		updateMouseLocation()
	}
	
	override func mouseExited(with event: NSEvent) {
		super.mouseExited(with: event)
		updateMouseLocation()
	}
	
	private var isHovered: Bool = false { didSet {
		if isHovered {
			showGlowLayers()
		}
		else {
			hideGlowLayers()
		}
	}}
	
	private func showGlowLayers() {
		CALayer.animate(enabled: true, duration: 0.25) {
			self.glowLayer1.opacity = 1.0
			self.glowLayer2.opacity = 1.0
		} completionHandler: {
			
		}
	}
	
	private func hideGlowLayers() {
		CALayer.animate(enabled: true, duration: 0.5) {
			self.glowLayer1.opacity = 0.0
			self.glowLayer2.opacity = 0.0
		} completionHandler: {
			
		}
	}
	
	private func updateMouseLocation() {
		guard let mouseLocationInView = mouseLocationInView()
		else {
			self.isHovered = false
			return
		}
		
		self.isHovered = self.bounds.contains(mouseLocationInView)
		
		CALayer.disableAnimations {
			self.glowLayer1.position = mouseLocationInView
		}
	}
	
}

private enum GradientLoopColorType {
	case typeA
	case typeB
	case typeC
	
	func nextType() -> GradientLoopColorType {
		switch self {
			case .typeA: return .typeB
			case .typeB: return .typeC
			case .typeC: return .typeA
		}
	}
	
	func gradientColors() -> [CGColor] {
		switch self {
			case .typeA:
				let mainColor = NSColor(deviceHue: 0.825, saturation: 0.85, brightness: 1.0, alpha: 1)
				return [
					mainColor.cgColor,
					mainColor.withAlphaComponent(0).cgColor,
				]
				
			case .typeB:
				let mainColor = NSColor(deviceHue: 0.75, saturation: 0.90, brightness: 1.0, alpha: 1)
				return [
					mainColor.cgColor,
					mainColor.withAlphaComponent(0).cgColor,
				]
				
			case .typeC:
				let mainColor = NSColor(deviceHue: 0.55, saturation: 0.93, brightness: 1.0, alpha: 1)
				return [
					mainColor.cgColor,
					mainColor.withAlphaComponent(0).cgColor,
				]
				
		}
	}
}

extension NSTextAlignment {
	
	func layerAlignmentMode() -> CATextLayerAlignmentMode {
		switch self {
			case .left:
				return .left
			case .center:
				return .center
			case .right:
				return .right
			case .justified:
				return .justified
			case .natural:
				return .natural
			@unknown default:
				return .left
		}
	}
	
}

extension NSView {
	
	func mouseLocationInView() -> NSPoint? {
		guard let window = self.window
		else { return nil }
		
		let mouseLocationInWindow = window.mouseLocationOutsideOfEventStream //window.convertPoint(fromScreen: NSEvent.mouseLocation)
		let mouseLocationInView = convert(mouseLocationInWindow, from: nil)
		return mouseLocationInView
	}
	
}

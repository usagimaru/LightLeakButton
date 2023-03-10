//
//  LightLeakButton.swift
//  LightLeakButton
//
//  Created by usagimaru on 2023/02/14.
//
//  Original design by drawsgood
//  https://rive.app/community/4402-9064-light-leak-button/
//  https://twitter.com/drawsgood/status/1626638647901491211

import Cocoa
import CAAnimationCallback

class LightLeakButton: NSControl {
	
	override var stringValue: String { didSet {
		self.labelLayer.string = stringValue
		
		if !self.prohibitToDisplayAndLayout {
			self.needsDisplay = true
		}
		invalidateIntrinsicContentSize()
	}}
	
	override var font: NSFont? { didSet {
		if !self.prohibitToDisplayAndLayout {
			self.needsDisplay = true
		}
		invalidateIntrinsicContentSize()
	}}
	
	/// Title horizontal alignment
	override var alignment: NSTextAlignment { didSet {
		if !self.prohibitToDisplayAndLayout {
			self.needsDisplay = true
		}
		invalidateIntrinsicContentSize()
	}}
	
	/// Title truncation
	var labelTruncationMode: CATextLayerTruncationMode = .end { didSet {
		if !self.prohibitToDisplayAndLayout {
			self.needsDisplay = true
		}
		invalidateIntrinsicContentSize()
	}}
	
	/// Corner radius
	var cornerRadius: CGFloat = 0 { didSet {
		if !self.prohibitToDisplayAndLayout {
			self.needsLayout = true
		}
	}}
	
	/// Duration for gradient animation
	var gradientAnimationStepDuration: TimeInterval = 1.7 { didSet {
		if !self.prohibitToDisplayAndLayout {
			self.needsDisplay = true
		}
	}}
	
	override var isHighlighted: Bool { didSet {
		if !self.prohibitToDisplayAndLayout {
			self.needsDisplay = true
		}
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
	
	var grooveWidth: CGFloat = 1.5 { didSet {
		if !self.prohibitToDisplayAndLayout {
			self.needsLayout = true
			self.needsDisplay = true
		}
	}}
	
	var backgroundColor: NSColor = NSColor(calibratedWhite: 0.1, alpha: 1) { didSet {
		if !self.prohibitToDisplayAndLayout {
			self.needsDisplay = true
		}
	}}
	
	private var prohibitToDisplayAndLayout: Bool = false
	private var isGradientLoopAnimating = false
	
	private var boundsClippingLayer = CALayer()
	private var innerClippingLayer = CALayer()
	private var labelBackLayer = CALayer()
	private var labelLayer = HollowingTextLayer()
	private var surfaceLayer = CAGradientLayer()
	
	private var glowLayer1 = CAGradientLayer()
	private var glowLayer2 = CAGradientLayer()
	private var haloLayer = CAGradientLayer()
	private var haloLayer_highlight = CAGradientLayer()
	
	private var highlightLayer = CAGradientLayer()
	
	
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
		/*
		 I would like to calculate the intrinsic size of a good fit to the width of the labelLayer,
		 but it does not work well. ????????
		 */
		
		let superSize = super.intrinsicContentSize
		
		updateTextLabelLayer()
		layout()
		
		let horizontalInsets: CGFloat = 20
		let verticalInsets: CGFloat = 12
		let textBounds = self.labelLayer.calculateTextBounds()
		
		return NSSize {
			textBounds.width + self.grooveWidth * 2 + horizontalInsets
		} h: {
			if textBounds.height + verticalInsets > superSize.height {
				return textBounds.height + verticalInsets
			}
			return superSize.height
		}
	}
	
	private func _init() {
		self.wantsLayer = true
		self.layerContentsRedrawPolicy = .onSetNeedsDisplay
		self.isEnabled = true
		self.font = NSFont.systemFont(ofSize: 20, weight: .bold)
		self.alignment = .center
		
		CALayer.disableAnimations {
			self.mainLayer.masksToBounds = false
			self.boundsClippingLayer.masksToBounds = true
			self.innerClippingLayer.masksToBounds = true
			self.labelBackLayer.masksToBounds = true
			self.labelLayer.masksToBounds = true
			
			self.mainLayer.addSublayer(self.boundsClippingLayer)
			self.mainLayer.addSublayer(self.haloLayer)
			self.mainLayer.addSublayer(self.haloLayer_highlight)
			
			self.boundsClippingLayer.addSublayer(self.glowLayer1)
			self.boundsClippingLayer.addSublayer(self.glowLayer2)
			self.boundsClippingLayer.addSublayer(self.highlightLayer)
			self.boundsClippingLayer.addSublayer(self.innerClippingLayer)
			
			self.innerClippingLayer.addSublayer(self.labelBackLayer)
			self.innerClippingLayer.addSublayer(self.surfaceLayer)
			self.labelBackLayer.mask = self.labelLayer
			
			resetTrackingArea()
		}
		
		self.needsLayout = true
		self.needsDisplay = true
		invalidateIntrinsicContentSize()
	}
	
	private func setupGradientLoopAnimation(_ type: GradientLoopColorType = .typeA, to layer: CAGradientLayer) {
		let gradientLoopAnim = "gradientLoop"
		
		if !self.isGradientLoopAnimating {
			layer.removeAnimation(forKey: gradientLoopAnim)
			return
		}
		
		let gradientAnim = CABasicAnimation(keyPath: "colors")
		gradientAnim.duration = self.gradientAnimationStepDuration
		gradientAnim.fillMode = CAMediaTimingFillMode.forwards
		gradientAnim.isRemovedOnCompletion = false
		gradientAnim.fromValue = type.gradientColors()
		gradientAnim.toValue = type.nextType().gradientColors()
		
		gradientAnim.completionHandler { [weak self] anim, flag in
			self?.setupGradientLoopAnimation(type.nextType(), to: layer)
		}
		
		layer.add(gradientAnim, forKey: gradientLoopAnim)
	}
	
	
	// MARK: -
	
	private func updateTextLabelLayer() {
		self.labelLayer.string = self.stringValue
		self.labelLayer.isWrapped = false
		self.labelLayer.font = self.font
		self.labelLayer.fontSize = self.font?.pointSize ?? 0
		self.labelLayer.truncationMode = self.labelTruncationMode
		self.labelLayer.alignmentMode = self.alignment.layerAlignmentMode()
		self.labelLayer.setNeedsDisplay()
	}
	
	override func updateLayer() {
		let backingScale = self.window?.backingScaleFactor ?? 1.0
		
		CALayer.disableAnimations {
			self.labelBackLayer.contentsScale = backingScale
			self.labelBackLayer.backgroundColor = self.backgroundColor.cgColor
			
			// Text Layer
			self.labelLayer.contentsScale = backingScale
			self.labelLayer.foregroundColor = nil
			self.labelLayer.backgroundFillColor = self.backgroundColor.cgColor
			self.labelLayer.isHollowing = true
			self.labelLayer.backgroundDrawing = nil
			updateTextLabelLayer()
			
			// Button Surface
			self.surfaceLayer.contentsScale = backingScale
			self.surfaceLayer.type = .axial
			self.surfaceLayer.startPoint = NSPoint(0.5, 0.9)
			self.surfaceLayer.endPoint = NSPoint(0.5, 0.2)
			self.surfaceLayer.colors = [
				NSColor.white.withAlphaComponent(0.02).cgColor,
				NSColor.black.withAlphaComponent(0).cgColor,
			]
			
			// Glow Layer 1 (animating)
			self.glowLayer1.contentsScale = backingScale
			self.glowLayer1.type = .radial
			self.glowLayer1.startPoint = NSPoint(0.5, 0.5)
			self.glowLayer1.endPoint = NSPoint(1, 1)
			self.glowLayer1.colors = GradientLoopColorType.typeA.gradientColors()
			self.glowLayer1.compositingFilter = "normalBlendMode"
			
			// Glow Layer 2
			self.glowLayer2.contentsScale = backingScale
			self.glowLayer2.type = .radial
			self.glowLayer2.startPoint = NSPoint(0.5, 0.5)
			self.glowLayer2.endPoint = NSPoint(1, 1)
			let glowColor2 = NSColor(deviceHue: 0.70, saturation: 0.46, brightness: 1.0, alpha: 1)
			self.glowLayer2.colors = [
				glowColor2.cgColor,
				glowColor2.withAlphaComponent(0).cgColor,
			]
			self.glowLayer2.compositingFilter = "colorDodgeBlendMode"
			
			// Highlight Layer (when pushing)
			self.highlightLayer.contentsScale = backingScale
			self.highlightLayer.type = .radial
			self.highlightLayer.startPoint = NSPoint(0.5, 0.5)
			self.highlightLayer.endPoint = NSPoint(1, 1)
			let HLColor = NSColor(deviceHue: 0.53, saturation: 0.44, brightness: 0.98, alpha: 1)
			self.highlightLayer.colors = [
				HLColor.cgColor,
				HLColor.withAlphaComponent(0).cgColor,
			]
			self.highlightLayer.compositingFilter = "hardLightBlendMode"
			
			// Halo Layer (animating)
			self.haloLayer.contentsScale = backingScale
			self.haloLayer.type = .radial
			self.haloLayer.startPoint = NSPoint(0.5, 0.5)
			self.haloLayer.endPoint = NSPoint(1, 1)
			self.haloLayer.colors = GradientLoopColorType.typeA.gradientColors()
			self.haloLayer.compositingFilter = "screenBlendMode"
			
			// Halo Layer (highlight)
			self.haloLayer_highlight.contentsScale = backingScale
			self.haloLayer_highlight.type = .radial
			self.haloLayer_highlight.startPoint = NSPoint(0.5, 0.5)
			self.haloLayer_highlight.endPoint = NSPoint(1, 1)
			self.haloLayer_highlight.colors = [
				HLColor.cgColor,
				HLColor.withAlphaComponent(0).cgColor,
			]
			self.haloLayer_highlight.compositingFilter = "screenBlendMode"
			
			// Visibility
			self.glowLayer1.isHidden = !self.isEnabled
			self.glowLayer2.isHidden = !self.isEnabled
			self.highlightLayer.isHidden = !self.isEnabled
			self.haloLayer.isHidden = !self.isEnabled
			self.haloLayer_highlight.isHidden = !self.isEnabled
		}
		
		if !self.isHovered {
			self.glowLayer1.opacity = 0.0
			self.glowLayer2.opacity = 0.0
			self.haloLayer.opacity = 0.0
			self.haloLayer_highlight.opacity = 0.0
		}
		
		// Visibility and animation on clicking
		if self.isHighlighted {
			CALayer.animate(enabled: true, duration: 0.08) {
				self.highlightLayer.opacity = 1.0
				self.haloLayer_highlight.opacity = 0.09
			}
		}
		else {
			CALayer.animate(enabled: true, duration: 0.75) {
				self.highlightLayer.opacity = 0.0
				self.haloLayer_highlight.opacity = 0.0
			}
		}
		
		if !self.isEnabled {
			self.boundsClippingLayer.backgroundColor = NSColor.black.withSystemEffect(.disabled).cgColor
			self.isGradientLoopAnimating = false
			setupGradientLoopAnimation(to: self.glowLayer1)
			setupGradientLoopAnimation(to: self.haloLayer)
		}
		else {
			self.boundsClippingLayer.backgroundColor = NSColor.black.cgColor
			
			// Gradient loop animations
			if !self.isGradientLoopAnimating {
				self.isGradientLoopAnimating = true
				setupGradientLoopAnimation(to: self.glowLayer1)
				setupGradientLoopAnimation(to: self.haloLayer)
			}
		}
		
		self.needsLayout = true
	}
	
	override func layout() {
		CALayer.disableAnimations {
			self.boundsClippingLayer.frame = self.bounds
			self.boundsClippingLayer.setCornerRadius(self.cornerRadius)
			
			let innerRadius = (self.cornerRadius > 0) ? max(self.cornerRadius - self.grooveWidth, 0) : 0
			self.innerClippingLayer.setCornerRadius(innerRadius)
			self.innerClippingLayer.frame = self.bounds.insetBy(self.grooveWidth)
			
			self.labelBackLayer.frame = self.innerClippingLayer.bounds
			self.labelBackLayer.setCornerRadius(innerRadius)
			
			self.labelLayer.constraintSizeOfFitting = self.labelBackLayer.frame.size
			self.labelLayer.display()
			self.labelLayer.size = self.labelBackLayer.frame.size
			
			self.labelLayer.origin = CGPoint(x: {
				(self.innerClippingLayer.frame.width - self.labelLayer.frame.width) / 2
			},
											 y: {
				(self.innerClippingLayer.frame.height - self.labelLayer.frame.height) / 2
			})
			
			self.surfaceLayer.frame = self.innerClippingLayer.frame
			
			
			// Glow 1
			// Do not reset the `origin` here, since the `position` is updated according to the mouse pointer.
			self.glowLayer1.size = effectLayerFrame(widthScale: 1.25, heightScale: 0.75).size
			
			// Glow 2
			self.glowLayer2.size = self.glowLayer1.size
			
			// Glow (highlight)
			self.highlightLayer.size = effectLayerFrame(widthScale: 4.0, heightScale: 2.4).size
			
			
			// Halo
			// The origin is fixed.
			self.haloLayer.frame = effectLayerFrame(widthScale: 1.5, heightScale: 0.7)
			
			// Halo (highlight)
			self.haloLayer_highlight.frame = effectLayerFrame(widthScale: 1.5,  heightScale: 0.7)
		}
		
		if self.labelLayer.isTextWrapped() {
			super.toolTip = self.stringValue
		}
		else {
			super.toolTip = self._toolTip
		}
		
		super.layout()
	}
	
	private func effectLayerFrame(widthScale: CGFloat = 1.0, heightScale: CGFloat = 1.0) -> CGRect {
		// Calculate the circumscribed regular circle and then multiply it by the vertical and horizontal scales.
		
		let width = self.bounds.size.maxElement()
		var layerFrame = CGRect(0, 0, width * widthScale, width * heightScale)
		
		// Center
		layerFrame.editX { rect in
			(self.bounds.width - rect.width) / 2
		}
		layerFrame.editY { rect in
			(self.bounds.height - rect.height) / 2
		}
		
		return layerFrame
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
		CALayer.animate(enabled: true, duration: 0.35) {
			self.glowLayer1.opacity = 1.0
			self.glowLayer2.opacity = 1.0
			self.haloLayer.opacity = self.isHighlighted ? 0.0 : 0.09
		}
	}
	
	private func hideGlowLayers() {
		CALayer.animate(enabled: true, duration: 0.8) {
			self.glowLayer1.opacity = 0.0
			self.glowLayer2.opacity = 0.0
			self.haloLayer.opacity = 0.0
		}
	}
	
	private func updateMouseLocation() {
		guard let mouseLocationInView = mouseLocationInView()
		else {
			self.isHovered = false
			return
		}
		
		self.isHovered = self.bounds.contains(mouseLocationInView)
		
		// Update the position of these layers according to the mouse pointer.
		CALayer.disableAnimations {
			self.glowLayer1.position = mouseLocationInView
			self.glowLayer2.position = mouseLocationInView
			self.highlightLayer.position = mouseLocationInView
		}
	}
	
	
	// MARK: - Tracking Area
	
	private var trackingArea: NSTrackingArea?
		
	private func resetTrackingArea() {
		if let trackingArea = self.trackingArea {
			removeTrackingArea(trackingArea)
		}
		
		let options: NSTrackingArea.Options = [
			.activeAlways,
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
	
	
	// MARK: - Events
	
	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		// Accespts mouse click event when the window is not key window or the app is not active.
		return true
	}
	
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
	
	override func mouseDragged(with event: NSEvent) {
		super.mouseDragged(with: event)
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

extension CATextLayerTruncationMode {
	
	func lineBreakMode() -> NSLineBreakMode {
		switch self {
			case .start:
				return .byTruncatingHead
				
			case .middle:
				return .byTruncatingMiddle
				
			case .end:
				return .byTruncatingTail
				
			default:
				return .byClipping
				
		}
	}
	
}

extension NSView {
	
	func mouseLocationInView() -> NSPoint? {
		guard let window = self.window
		else { return nil }
		
		let mouseLocationInWindow = window.mouseLocationOutsideOfEventStream
		let mouseLocationInView = convert(mouseLocationInWindow, from: nil)
		return mouseLocationInView
	}
	
}

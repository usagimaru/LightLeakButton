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
		let superSize = super.intrinsicContentSize
		
		layout()
		
		return NSSize {
			self.labelLayer.calculateTextBounds().width + self.grooveWidth * 2 + 12
		} h: {
			self.labelLayer.calculateTextBounds().height + self.grooveWidth * 2
		}

	}
	
	private func _init() {
		self.wantsLayer = true
		self.layerContentsRedrawPolicy = .duringViewResize
		
		self.font = NSFont.systemFont(ofSize: 20, weight: .bold)
		self.alignment = .center
		
		CALayer.disableAnimations {
			self.mainLayer.masksToBounds = false
			self.boundsLayer.masksToBounds = true
			
			self.mainLayer.addSublayer(self.boundsLayer)
			self.boundsLayer.addSublayer(self.glowLayer1)
			self.boundsLayer.addSublayer(self.glowLayer2)
			self.boundsLayer.addSublayer(self.highlightLayer)
			self.boundsLayer.addSublayer(self.innerContentLayer)
			self.boundsLayer.addSublayer(self.labelBackLayer)
			self.boundsLayer.addSublayer(self.labelLayer)
			self.boundsLayer.addSublayer(self.surfaceLayer)
			self.mainLayer.addSublayer(self.haloLayer)
			self.mainLayer.addSublayer(self.haloLayer_highlight)
			
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
	
	private func setupGradientLoopAnimation(_ type: GradientLoopColorType = .typeA, to layer: CAGradientLayer) {
		if !self.isGradientLoopAnimating {
			layer.removeAnimation(forKey: "gradientLoop")
			return
		}
		
		let gradientAnim = CABasicAnimation(keyPath: "colors")
		gradientAnim.duration = 2.5
		gradientAnim.fillMode = CAMediaTimingFillMode.forwards
		gradientAnim.isRemovedOnCompletion = false
		gradientAnim.fromValue = type.gradientColors()
		gradientAnim.toValue = type.nextType().gradientColors()
		
		gradientAnim.completionHandler { [weak self] anim, flag in
			self?.setupGradientLoopAnimation(type.nextType(), to: layer)
		}
		
		layer.add(gradientAnim, forKey: "gradientLoop")
	}
	
	
	// MARK: -
	
	private func updateTextLabelLayer() {
		self.labelLayer.string = self.stringValue
		self.labelLayer.font = self.font
		self.labelLayer.fontSize = self.font?.pointSize ?? 0
		self.labelLayer.truncationMode = self.labelTruncationMode
		self.labelLayer.alignmentMode = self.alignment.layerAlignmentMode()
	}
	
	override func updateLayer() {
		let backingScale = self.window?.backingScaleFactor ?? 1.0
		
		CALayer.disableAnimations {
			self.boundsLayer.backgroundColor = NSColor.black.cgColor
			
			// Text Layer
			self.labelLayer.contentsScale = backingScale
			self.labelLayer.foregroundColor = nil
			self.labelLayer.isWrapped = false
			self.labelLayer.masksToBounds = true
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
			
			// Highlight Layer
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
			
			// Halo Layer
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
		}
		
		if !self.isHovered {
			self.glowLayer1.opacity = 0.0
			self.glowLayer2.opacity = 0.0
			self.haloLayer.opacity = 0.0
			self.haloLayer_highlight.opacity = 0.0
		}
		
		// クリック時の見た目とアニメーション
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
		
		// ループアニメーション
		if !self.isGradientLoopAnimating {
			self.isGradientLoopAnimating = true
			setupGradientLoopAnimation(to: self.glowLayer1)
			setupGradientLoopAnimation(to: self.haloLayer)
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
			
			
			self.surfaceLayer.frame = self.innerContentLayer.frame
			
			
			// Glow 1: 1.25x width, 0.75x height
			self.glowLayer1.frame = effectLayerFrame(widthScale: 1.25, heightScale: 0.75)
			
			// Glow 2: 1.25x width, 0.75x height
			self.glowLayer2.frame = self.glowLayer1.frame
			
			// Highlight 3: 4x width, 2.4x height
			self.highlightLayer.frame = effectLayerFrame(widthScale: 4.0, heightScale: 2.4)
			
			// Halo
			self.haloLayer.frame = effectLayerFrame(widthScale: 1.5, heightScale: 0.7)
			
			// Halo (highlight)
			self.haloLayer_highlight.frame = effectLayerFrame(widthScale: 1.5, heightScale: 0.7)
		}
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
		
		// Update layer position to mouse location
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

extension NSView {
	
	func mouseLocationInView() -> NSPoint? {
		guard let window = self.window
		else { return nil }
		
		let mouseLocationInWindow = window.mouseLocationOutsideOfEventStream //window.convertPoint(fromScreen: NSEvent.mouseLocation)
		let mouseLocationInView = convert(mouseLocationInWindow, from: nil)
		return mouseLocationInView
	}
	
}

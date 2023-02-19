//
//  HollowingTextLayer.swift
//
//  Created by usagimaru on 2023/02/19.
//

import QuartzCore
#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

class HollowingTextLayer: CATextLayer {
	
#if os(macOS)
	typealias Color = NSColor
	typealias Font = NSFont
#elseif os(iOS)
	typealias Color = UIColor
	typealias Font = UIFont
#endif
	
	/// Enable hollowing
	var isHollowing: Bool = true { didSet {
		self.needsDisplay()
	}}
	
	/// Adjust for text centering vertically
	var centeringVerticallyTweaking: Bool = true { didSet {
		self.needsDisplay()
	}}
	
	/// Can adjust text align vertically if needed. +0.5 is solving the visually misalignment.
	var yVisualGap: CGFloat = 0 { didSet {
		self.needsDisplay()
	}}
	
	/// Draw backgroud
	var backgroundDrawing: ((_ ctx: CGContext) -> ())?
	
	/// Alternative to `backgroundColor`
	var backgroundFillColor: CGColor = Color.clear.cgColor
	
	/// Limitation of `fittingSize()` calculation
	var constraintSizeOfFitting: CGSize = .zero
	
	override var backgroundColor: CGColor? {
		get {
			nil
		}
		set {
			fatalError("Use `backgroundFillColor` instead of `backgroundColor`")
		}
	}
	
	
	// MARK: -
	
	@discardableResult
	func fittingSize() -> CGSize {
		let textBounds = calculateTextBounds()
		CALayer.disableAnimations {
			self.size = textBounds.size
		}
		return textBounds.size
	}
	
	func calculateTextBounds() -> CGRect {
		guard let string = self.string as? String,
			  let font = self.font
		else { return .zero }
		
		let attStr = NSMutableAttributedString(string: string, attributes:
												[
													.font : font,
												])
		let textRect = attStr.boundingRect(with: self.constraintSizeOfFitting, options: [
			.usesLineFragmentOrigin
		], context: nil)
		
		return textRect
	}
	
	func isTextWrapped() -> Bool {
		let textWidth = calculateTextBounds().width
		return self.bounds.width < textWidth
	}
	
	
	// MARK: -
	
	override func draw(in ctx: CGContext) {
		drawBackground(ctx)
		drawText(ctx)
	}
	
	/// Draw background
	private func drawBackground(_ ctx: CGContext) {
		ctx.saveGState()
		
		if let backgroundDrawing = self.backgroundDrawing {
			backgroundDrawing(ctx)
		}
		else {
			ctx.setFillColor(self.backgroundFillColor)
			ctx.addRect(self.bounds)
			ctx.fillPath()
		}
		
		ctx.restoreGState()
	}
	
	/// Draw text
	private func drawText(_ ctx: CGContext) {
		// Center text vertically and hollow out it from the background.
		
		ctx.saveGState()
		
		// Adjust vertical text position
		if self.centeringVerticallyTweaking {
			var yGap1: CGFloat {
				// Method #1:
				// "(height - fontSize) / 2 - fontSize / 10.0"
				// https://stackoverflow.com/questions/4765461/vertically-align-text-in-a-catextlayer
				
				let height = self.bounds.height
				let fontSize = self.fontSize
				
				if self.isGeometryFlipped {
					return (height - fontSize) / 2 - fontSize / 10.0
				}
				else {
					return -(height - fontSize) / 2 + fontSize / 10.0
				}
			}
			
			var yGap2: CGFloat {
				// Method #2:
				// Calculate the gap with "ascent - pointSize" then add to y-translate value it.
				
				guard let font = self.font as? Font
				else { return 0 }
				
				return -(font.ascender - font.pointSize)
			}
			
			// I see that the Method #2 is apparently the most vertically centered.
			let yGap = self.yVisualGap + yGap1 + yGap2
			ctx.translateBy(x: 0, y: yGap)
		}
		
		// Hollow out text
		if self.isHollowing {
			ctx.setBlendMode(.clear)
		}
		
		// Call default drawing process
		super.draw(in: ctx)
		
		ctx.restoreGState()
	}
	
}

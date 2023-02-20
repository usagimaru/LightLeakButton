//
//  CGGeometry.swift
//
//  Copyright © 2019 usagimaru.
//

import CoreGraphics

extension CGPoint {
	
	init(_ x: CGFloat = 0,
		 _ y: CGFloat = 0) {
		self.init(x: x, y: y)
	}
	
	init(x: () -> CGFloat = {0},
		 y: () -> CGFloat = {0}) {
		self.init(x(), y())
	}
	
	
	// MARK: -
	
	mutating func editX(_ editor: () -> CGFloat?) {
		if let v = editor() {
			x = v
		}
	}
	
	mutating func editY(_ editor: () -> CGFloat?) {
		if let v = editor() {
			y = v
		}
	}
	
	
	// MARK: -
	
	mutating func round() {
		x = Darwin.round(x)
		y = Darwin.round(y)
	}

	func rounded() -> CGPoint {
		var p = self
		p.round()
		return p
	}

	func distance(to location: CGPoint) -> CGFloat {
		let distance = abs(sqrt(pow(location.x - x, 2) + pow(location.y - y, 2)))
		return distance
	}

	func radian(to location: CGPoint) -> CGFloat {
		let radian = atan2(location.y - y, location.x - x)
		// let degree = radian * 180 / CGFloat.pi
		return radian
	}
	
	func maxElement() -> CGFloat {
		max(x, y)
	}
	
	func minElement() -> CGFloat {
		min(x, y)
	}

	mutating func add(x: CGFloat, y: CGFloat) {
		self.x += x
		self.y += y
	}

	func added(x: CGFloat, y: CGFloat) -> CGPoint {
		CGPoint(x: self.x + x, y: self.y + y)
	}

	static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}

	static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}

	static func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
	}

	static func / (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
	}

	func flippedHorizontally(_ width: CGFloat, coefficient: CGFloat) -> CGPoint {
		added(x: width * coefficient, y: 0)
	}

	func flippedVertically(_ height: CGFloat, coefficient: CGFloat) -> CGPoint {
		added(x: 0, y: height * coefficient)
	}

	func flipped(_ size: CGSize, coefficient: CGFloat) -> CGPoint {
		added(x: size.width * coefficient, y: size.height * coefficient)
	}
}

extension CGSize {
	
	init(_ width: CGFloat = 0,
		 _ height: CGFloat = 0) {
		self.init(width: width, height: height)
	}
	
	init(w: () -> CGFloat = {0},
		 h: () -> CGFloat = {0}) {
		self.init(w(), h())
	}
	
	
	// MARK: -
	
	mutating func editWidth(_ editor: () -> CGFloat?) {
		if let v = editor() {
			width = v
		}
	}
	
	mutating func editHeight(_ editor: () -> CGFloat?) {
		if let v = editor() {
			height = v
		}
	}
	
	
	// MARK: -
	
	mutating func round() {
		width = Darwin.round(width)
		height = Darwin.round(height)
	}

	func rounded() -> CGSize {
		var s = self
		s.round()
		return s
	}

	mutating func abs() {
		width = Swift.abs(width)
		height = Swift.abs(height)
	}

	func absSize() -> CGSize {
		var s = self
		s.abs()
		return s
	}
	
	func maxElement() -> CGFloat {
		max(width, height)
	}
	
	func minElement() -> CGFloat {
		min(width, height)
	}

	mutating func add(width: CGFloat, height: CGFloat) {
		self.width += width
		self.height += height
	}

	func added(width: CGFloat, height: CGFloat) -> CGSize {
		CGSize(width: self.width + width, height: self.height + height)
	}

	static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
		CGSize(width: lhs.width + rhs.width, height: lhs.width + rhs.width)
	}

	static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
		CGSize(width: lhs.width - rhs.width, height: lhs.width - rhs.width)
	}

	static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
		CGSize(width: lhs.width * rhs.width, height: lhs.width * rhs.width)
	}

	static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
		CGSize(width: lhs.width / rhs.width, height: lhs.width / rhs.width)
	}

	func multiplied(by scale: CGFloat) -> CGSize {
		var s = self
		s.multiply(scale)
		return s
	}

	mutating func multiply(_ scale: CGFloat) {
		width *= scale
		height *= scale
	}
	
	func multiplied(scaleX: CGFloat, scaleY: CGFloat) -> CGSize {
		var s = self
		s.multiply(scaleX: scaleX, scaleY: scaleY)
		return s
	}
	
	mutating func multiply(scaleX: CGFloat, scaleY: CGFloat) {
		width *= scaleX
		height *= scaleY
	}

	func divided(by scale: CGFloat) -> CGSize {
		var s = self
		s.divide(scale)
		return s
	}

	mutating func divide(_ scale: CGFloat) {
		width /= scale
		height /= scale
	}
	
	func halfSize() -> CGSize {
		multiplied(by: 0.5)
	}
	
	mutating func half() {
		multiply(0.5)
	}
	
	func smallerSide() -> CGFloat {
		min(width, height)
	}
	
	func largerSide() -> CGFloat {
		max(width, height)
	}
}

extension CGRect {
	
	init(_ x: CGFloat = 0,
		 _ y: CGFloat = 0,
		 _ width: CGFloat = 0,
		 _ height: CGFloat = 0) {
		self.init(x: x, y: y, width: width, height: height)
	}
	
	init(_ origin: CGPoint = .zero, _ size: CGSize = .zero) {
		self.init(origin: origin, size: size)
	}
	
	init(x: () -> CGFloat = {0},
		 y: () -> CGFloat = {0},
		 w: () -> CGFloat = {0},
		 h: () -> CGFloat = {0}) {
		self.init(x(), y(), w(), h())
	}
	
	init(origin: () -> CGPoint = {.zero},
		 size: () -> CGSize = {.zero}) {
		self.init(origin(), size())
	}
	
	
	// MARK: -
	
	mutating func editX(_ editor: (_ rect: CGRect) -> CGFloat?) {
		if let v = editor(self) {
			self.origin.x = v
		}
	}
	
	mutating func editY(_ editor: (_ rect: CGRect) -> CGFloat?) {
		if let v = editor(self) {
			self.origin.y = v
		}
	}
	
	mutating func editWidth(_ editor: (_ rect: CGRect) -> CGFloat?) {
		if let v = editor(self) {
			self.size.width = v
		}
	}
	
	mutating func editHeight(_ editor: (_ rect: CGRect) -> CGFloat?) {
		if let v = editor(self) {
			self.size.height = v
		}
	}
	
	mutating func editOrigin(_ editor: (_ rect: CGRect) -> CGPoint?) {
		if let v = editor(self) {
			self.origin = v
		}
	}
	
	mutating func editSize(_ editor: (_ rect: CGRect) -> CGSize?) {
		if let v = editor(self) {
			self.size = v
		}
	}
	
	mutating func edit(x: ((_ rect: CGRect) -> CGFloat?)? = nil,
					   y: ((_ rect: CGRect) -> CGFloat?)? = nil,
					   w: ((_ rect: CGRect) -> CGFloat?)? = nil,
					   h: ((_ rect: CGRect) -> CGFloat?)? = nil) {
		if let x = x?(self) {
			self.origin.x = x
		}
		if let y = y?(self) {
			self.origin.y = y
		}
		if let w = w?(self) {
			self.size.width = w
		}
		if let h = h?(self) {
			self.size.height = h
		}
	}
	
	mutating func round() {
		origin.round()
		size.round()
	}
	
	
	// MARK: -

	func rounded() -> CGRect {
		var r = self
		r.round()
		return r
	}

	mutating func ceil() {
		origin.x = Darwin.ceil(origin.x)
		origin.y = Darwin.ceil(origin.y)
		size.width = Darwin.ceil(size.width)
		size.height = Darwin.ceil(size.height)
	}

	func ceilRect() -> CGRect {
		var r = self
		r.ceil()
		return r
	}

	func center() -> CGPoint {
		CGPoint(x: midX, y: midY)
	}

	func edges() -> CGRectEdges {
		CGRectEdges(rect: self)
	}
	
	func insetBy(_ d: CGFloat) -> CGRect {
		insetBy(dx: d, dy: d)
	}
	
	func offsetBy(_ d: CGFloat) -> CGRect {
		offsetBy(dx: d, dy: d)
	}
}

struct CGRectEdges {
	var top: CGFloat
	var left: CGFloat
	var bottom: CGFloat
	var right: CGFloat

	init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
		self.top = top
		self.left = left
		self.bottom = bottom
		self.right = right
	}

	init(rect: CGRect) {
		top = rect.minY
		left = rect.minX
		bottom = rect.maxY
		right = rect.maxX
	}

	func rect() -> CGRect {
		CGRect(x: left,
		       y: top,
		       width: right - left,
		       height: bottom - top)
	}
}

struct CGRectNullableEdges {
	var top: CGFloat?
	var left: CGFloat?
	var bottom: CGFloat?
	var right: CGFloat?

	init(top: CGFloat?, left: CGFloat?, bottom: CGFloat?, right: CGFloat?) {
		self.top = top
		self.left = left
		self.bottom = bottom
		self.right = right
	}

	init(rect: CGRect) {
		top = rect.minY
		left = rect.minX
		bottom = rect.maxY
		right = rect.maxX
	}
}

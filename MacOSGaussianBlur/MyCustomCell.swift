//
//  MyCustomCell.swift
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 12.06.2022.
//

import Cocoa

class MyCustomCell: NSButtonCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        let path = NSBezierPath(roundedRect: cellFrame, xRadius: 10, yRadius: 10)

        if isHighlighted {
            NSColor.red.withAlphaComponent(0.5).set()
        } else {
            NSColor.red.set()
        }

        path.fill()
    }
    
    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        let attributedString = NSMutableAttributedString(attributedString:title)
        attributedString.addAttribute(.foregroundColor, value: NSColor.white, range:
        NSRange(location: 0,length: attributedString.string.count))
        return super.drawTitle(attributedString, withFrame: frame, in: controlView)
    }
    
    
}

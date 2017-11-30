//
//  URLAttachmentCell.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/25.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

let MARGIN_X: CGFloat = 12.0
let MARGIN_Y: CGFloat = 6.0
let ICON_SIZE: CGFloat = 16.0

class URLAttachmentCell: NSTextAttachmentCell {
    var textSize: NSSize {
        let text = self.stringValue as NSString
        return text.size(withAttributes: nil)
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        commonDraw(withFrame: cellFrame, in: controlView)
    }
    
    func commonDraw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        // 角丸四角形を描く
        let rrectPath = NSBezierPath(roundedRect: cellFrame, xRadius: 5.0, yRadius: 5.0)
        NSColor.lightGray.setFill()
        rrectPath.fill()
        
        
        let iconSize = NSSize(width: ICON_SIZE, height: ICON_SIZE)
        var iconPoint = NSPoint(x: cellFrame.origin.x, y: cellFrame.origin.y)
        
        if let iconImage = self.image {
            iconPoint.x += MARGIN_X
            iconPoint.y += MARGIN_Y
            
            iconImage.size = iconSize
            iconImage.draw(in: CGRect(origin: iconPoint, size: iconSize))
        }
        
        let text = self.stringValue as NSString
        var textOrigin = NSPoint()
        var textSize = NSSize()
        textOrigin.x = cellFrame.origin.x + MARGIN_X
        textOrigin.y = cellFrame.origin.y + cellSize().height/2 - text.size(withAttributes: nil).height/2
        if iconSize.width > 0 {
            textOrigin.x += iconSize.width + MARGIN_X
        }
        textSize.width = cellFrame.size.width - (textOrigin.x - cellFrame.origin.x)
        textSize.height = cellFrame.size.height
        
        let textRect = CGRect(origin: textOrigin, size: textSize)
        
        text.draw(in: textRect, withAttributes: nil)
    }
    
    override func cellSize() -> NSSize {
        let text = self.stringValue as NSString
        var size = text.size(withAttributes: nil)
        size.height = max(size.height + 2*MARGIN_Y, ICON_SIZE + 2*MARGIN_Y)
        size.width += MARGIN_X*3 + ICON_SIZE
        
        return size
    }
}

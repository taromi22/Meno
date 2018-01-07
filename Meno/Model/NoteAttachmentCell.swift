//
//  NoteAttachmentCell.swift
//  Meno
//
//  Created by 柳谷太郎 on 2018/01/07.
//  Copyright © 2018年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class NoteAttachmentCell: NSTextAttachmentCell {
    var textSize: NSSize {
        let text = self.stringValue as NSString
        return text.size(withAttributes: nil)
    }
    
    override var attachment: NSTextAttachment? {
        didSet {
            update()
        }
    }
    
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        commonDraw(withFrame: cellFrame, in: controlView)
    }
    
    func commonDraw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        // 外側のマージンの分を縮める
        var drawingFrame = cellFrame.insetBy(dx: 0.5, dy: 0.5)
        drawingFrame.origin.x += MARGIN_OUT_X
        drawingFrame.size.width -= 2*MARGIN_OUT_X
        
        // 角丸四角形を描く
        let rrectPath = NSBezierPath(roundedRect: drawingFrame, xRadius: 5.0, yRadius: 5.0)
        rrectPath.setLineDash([1.0, 2.0], count: 2, phase: 0.0)
        rrectPath.lineWidth = 1.0
        NSColor.black.set()
        rrectPath.stroke()
        
        let text = self.stringValue as NSString
        let textOrigin = NSPoint(x: drawingFrame.origin.x + MARGIN_X, y: drawingFrame.origin.y + drawingFrame.height/2 - text.size(withAttributes: nil).height/2)
        let textSize = NSSize(width: drawingFrame.size.width - 2*MARGIN_X, height: drawingFrame.size.height)
        let textRect = CGRect(origin: textOrigin, size: textSize)
        
        text.draw(in: textRect, withAttributes: nil)
    }
    
    func update() {
        if let data = self.attachment?.fileWrapper?.regularFileContents {
            if let profile = NSKeyedUnarchiver.unarchiveObject(with: data) as? NoteProfile {
                self.stringValue = profile.titleForPresentation
            }
        }
    }
    
    override func cellSize() -> NSSize {
        var cellsize = NSSize()
        
        cellsize.height = textSize.height + 2*MARGIN_Y
        cellsize.width = textSize.width + 2*MARGIN_X + 2*MARGIN_OUT_X + 2.0
        
        return cellsize
    }
}

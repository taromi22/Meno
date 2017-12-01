//
//  URLAttachmentCell.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/25.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

let MARGIN_X: CGFloat = 8.0
let MARGIN_Y: CGFloat = 3.0
let MARGIN_OUT_X: CGFloat = 4.0
let ICON_SIZE: CGFloat = 16.0

class URLAttachmentCell: NSTextAttachmentCell {
    var textSize: NSSize {
        let text = self.stringValue as NSString
        return text.size(withAttributes: nil)
    }
    
    override var attachment: NSTextAttachment? {
        didSet {
            if attachment?.contents != nil {
                if let url = URL(dataRepresentation: attachment!.contents!, relativeTo: nil) {
                    self.stringValue = url.lastPathComponent
                    
                    let ws = NSWorkspace.shared
                    
                    self.image = ws.icon(forFile: url.path)
                }
            } else if attachment?.fileWrapper != nil {
                if let data = attachment!.fileWrapper!.regularFileContents,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    self.stringValue = url.lastPathComponent
                    
                    let ws = NSWorkspace.shared
                    
                    self.image = ws.icon(forFile: url.path)
                }
            }
        }
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        commonDraw(withFrame: cellFrame, in: controlView)
    }
    
    func commonDraw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        // 外側のマージンの分を縮める
        var drawingFrame = cellFrame
        drawingFrame.origin.x += MARGIN_OUT_X
        drawingFrame.size.width -= 2*MARGIN_OUT_X
        
        // 角丸四角形を描く
        let rrectPath = NSBezierPath(roundedRect: drawingFrame, xRadius: 5.0, yRadius: 5.0)
        NSColor.lightGray.setFill()
        rrectPath.fill()
        
        let iconSize = NSSize(width: ICON_SIZE, height: ICON_SIZE)
        let iconOrigin = NSPoint(x: drawingFrame.origin.x + MARGIN_X, y: drawingFrame.origin.y + MARGIN_Y)
        
        let text = self.stringValue as NSString
        var textOrigin = NSPoint(x: drawingFrame.origin.x + MARGIN_X, y: drawingFrame.origin.y + drawingFrame.height/2 - text.size(withAttributes: nil).height/2)
        var textSize = NSSize(width: drawingFrame.size.width - 2*MARGIN_X, height: drawingFrame.size.height)
        
        // 画像が存在する場合、画像の大きさとスペースの分を空ける
        if let iconImage = self.image {
            iconImage.size = iconSize
            iconImage.draw(in: CGRect(origin: iconOrigin, size: iconSize))
            
            textOrigin.x += iconSize.width + MARGIN_X
            textSize.width -= iconSize.width + MARGIN_X
        }
        
        let textRect = CGRect(origin: textOrigin, size: textSize)
        
        text.draw(in: textRect, withAttributes: nil)
    }
    
    override func cellSize() -> NSSize {
        var cellsize = NSSize()
        
        if self.image != nil {
            cellsize.height = max(textSize.height, ICON_SIZE) + 2*MARGIN_Y
            cellsize.width = textSize.width + 3*MARGIN_X + ICON_SIZE + 2*MARGIN_OUT_X + 1.0 // 微妙に見切れる問題を解決するため
        } else {
            cellsize.height = textSize.height + 2*MARGIN_Y
            cellsize.width = textSize.width + 2*MARGIN_X + 2*MARGIN_OUT_X + 1.0
        }
        
        return cellsize
    }
    
}

extension String {
    private var nsstring: NSString {
        return (self as NSString)
    }
    
    public func substring(from index: Int) -> String {
        return nsstring.substring(from: index)
    }
    
    public func substring(to index: Int) -> String {
        return nsstring.substring(to: index)
    }
    
    public func substring(with range: NSRange) -> String {
        return nsstring.substring(with: range)
    }
    
    public var lastPathComponent: String {
        return nsstring.lastPathComponent
    }
    
    public var pathExtension: String {
        return nsstring.pathExtension
    }
    
    public var deletingLastPathComponent: String {
        return nsstring.deletingLastPathComponent
    }
    
    public var deletingPathExtension: String {
        return nsstring.deletingPathExtension
    }
    
    public var pathComponents: [String] {
        return nsstring.pathComponents
    }
    
    public func appendingPathComponent(_ str: String) -> String {
        return nsstring.appendingPathComponent(str)
    }
    
    public func appendingPathExtension(_ str: String) -> String? {
        return nsstring.appendingPathExtension(str)
    }
}

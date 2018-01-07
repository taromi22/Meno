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
    
    var originPath: String? {
        didSet {
            update()
        }
    }
    var textSize: NSSize {
        let text = self.stringValue.lastPathComponent as NSString
        return text.size(withAttributes: nil)
    }
    
    init(originPath: String) {
        super.init()
        
        self.originPath = originPath
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.originPath = coder.decodeObject(of: NSString.self, forKey: "originPath") as String?
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        aCoder.encode(self.originPath, forKey: "originPath")
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
        var drawingFrame = cellFrame
        drawingFrame.origin.x += MARGIN_OUT_X
        drawingFrame.size.width -= 2*MARGIN_OUT_X
        
        // 角丸四角形を描く
        let rrectPath = NSBezierPath(roundedRect: drawingFrame, xRadius: 5.0, yRadius: 5.0)
        NSColor.init(calibratedWhite: 0.85, alpha: 1.0).setFill()
        rrectPath.fill()
        
        let iconSize = NSSize(width: ICON_SIZE, height: ICON_SIZE)
        let iconOrigin = NSPoint(x: drawingFrame.origin.x + MARGIN_X, y: drawingFrame.origin.y + MARGIN_Y)
        
        let text = self.stringValue.lastPathComponent as NSString
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
    
    func update() {
        if let name = self.attachment?.fileWrapper?.preferredFilename {
            let ws = NSWorkspace.shared
            
            self.stringValue = name.deletingPathExtension.deletingPathExtension
            
            if let originPath = self.originPath,
                let fullpath = self.stringValue.stringOfFullPath(basePath: originPath) {
                
                self.image = ws.icon(forFile: fullpath)
            }
        }
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
    
    public func stringOfFullPath(basePath: String) -> String? {
        var basePathComponents = basePath.pathComponents
        var relativePathComponents = nsstring.pathComponents
        
        if relativePathComponents.count == 0 {
            return basePath
        }
        
        while basePathComponents.count > 0 {
            if relativePathComponents[0] == ".." {
                basePathComponents.removeLast()
                relativePathComponents.removeFirst()
            } else {
                break
            }
        }
        
        if basePathComponents.count == 0 { return nil }
        
        return NSString.path(withComponents: basePathComponents + relativePathComponents)
    }
    
    public func stringOfRelativePath(basePath: String) -> String {
        var basePathComponents = basePath.pathComponents
        var relativePathComponents = nsstring.pathComponents
        
        while basePathComponents.count > 0 && relativePathComponents.count > 0 {
            if basePathComponents[0] == relativePathComponents.first! {
                basePathComponents.removeFirst()
                relativePathComponents.removeFirst()
            } else {
                break
            }
        }
        if basePathComponents.count == 0 {
            return NSString.path(withComponents: relativePathComponents)
        } else {
            return NSString.path(withComponents: [String].init(repeating: "..", count: basePathComponents.count) + relativePathComponents)
        }
    }
}

protocol URLAttachmentCellDelegate {
    var originPath: String { get }
}

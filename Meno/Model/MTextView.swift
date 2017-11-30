//
//  MTextView.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/20.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class MTextView: NSTextView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        self.registerForDraggedTypes([.fileURL])
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    func shouldHandleDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        let pboard = draggingInfo.draggingPasteboard()
        
        if pboard.canReadObject(forClasses: [NSURL.self], options: nil) &&
            draggingInfo.draggingSource() as AnyObject? !== self {
            return true
        }
        return false
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return shouldHandleDrag(sender) ? [.link] : super.draggingEntered(sender)
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if shouldHandleDrag(sender) {
            return true
        } else {
            return super.prepareForDragOperation(sender)
        }
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard()
        
        if !shouldHandleDrag(sender) {
            return super.performDragOperation(sender)
        }
        
        let dropPoint = self.convert(sender.draggingLocation(), from: nil)
        let caretLocation = self.characterIndexForInsertion(at: dropPoint)

        if let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
            let storage = self.textStorage {
//
//            storage.beginEditing()
//
//            for url in urls {
//                let addedText = NSMutableAttributedString(string: url.relativePath, attributes: [.link: url])
//                addedText.insert(NSAttributedString(string: " "), at: 0)
//                addedText.insert(NSAttributedString(string: " "), at: addedText.length)
//
//                storage.insert(addedText, at: caretLocation)
//            }
//
//            storage.endEditing()
            let ws = NSWorkspace.shared
            
            for url in urls {
                if let path = url.path.removingPercentEncoding {
                    let cell = URLAttachmentCell()
                    let textAttachment = NSTextAttachment(data: url.dataRepresentation, ofType: kUTTypeFileURL as String) // UTF8でエンコードされている
                    textAttachment.attachmentCell = cell
                    
                    let cellstring = NSAttributedString(attachment: textAttachment)
                    storage.insert(cellstring, at: caretLocation)
                }
            }

            self.display()

            return true
        }
        return false
    }
    
    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if let storage = self.textStorage {
            let range = storage.editedRange
        
            storage.enumerateAttributes(in: range, options: .longestEffectiveRangeNotRequired)
            { (attributes, range, stop) in
                for attribute in attributes {
                    if attribute.key == NSAttributedStringKey.attachment {
                        let attachment = attribute.value as! NSTextAttachment
                        
                        self.replaceAttachmentCell(attachment: attachment)
                    }
                }
            }
        }
    }
    
    func replaceAttachmentCell(attachment: NSTextAttachment) {
        if attachment.attachmentCell is URLAttachmentCell {
            return
        }
        
        let cell = attachment.attachmentCell as! NSTextAttachmentCell
        let image = cell.image
        let text = cell.stringValue
        let newCell = URLAttachmentCell()
        newCell.image = image
        newCell.stringValue = text
        
        attachment.attachmentCell = newCell
    }
}

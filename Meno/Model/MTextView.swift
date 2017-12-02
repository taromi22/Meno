//
//  MTextView.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/20.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa
import Quartz

class MTextView: NSTextView, NSTextViewDelegate, NSTextStorageDelegate {
    
    var selectingURL: URL?
    
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
        self.delegate = self
        self.textStorage?.delegate = self
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

    // 今の所絶対URLを使っている　ゆくゆくは相対パスにしたい（相対URLというのがある？）
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard()

        if !shouldHandleDrag(sender) {
            return super.performDragOperation(sender)
        }

        let dropPoint = self.convert(sender.draggingLocation(), from: nil)
        let caretLocation = self.characterIndexForInsertion(at: dropPoint)

        if let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
            let storage = self.textStorage {

            for url in urls {
                if let path = url.path.removingPercentEncoding {
                    let cell = URLAttachmentCell()
                    let textAttachment = NSTextAttachment(fileWrapper: self.fileWrapper(with: "url", data: url.dataRepresentation))
                    
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
    func fileWrapper(with identifier: String, data: Data) -> FileWrapper {
        let wrapName = identifier.appendingPathExtension("meno")?.appendingPathExtension("url")
        let wrapper = FileWrapper(regularFileWithContents: data)
        
        wrapper.filename = wrapName
        wrapper.preferredFilename = wrapName
        
        return wrapper
    }
    
    func textView(_ view: NSTextView, writablePasteboardTypesFor cell: NSTextAttachmentCellProtocol, at charIndex: Int) -> [NSPasteboard.PasteboardType] {
        return [NSPasteboard.PasteboardType.fileURL]
    }

    
    // 外にドラッグするときにちゃんとファイルURLをコピーしたい
    func textView(_ view: NSTextView, write cell: NSTextAttachmentCellProtocol, at charIndex: Int, to pboard: NSPasteboard, type: NSPasteboard.PasteboardType) -> Bool {
        if type == .fileURL && cell is URLAttachmentCell {
            if let data = cell.attachment?.fileWrapper?.regularFileContents,
               let url = URL(dataRepresentation: data, relativeTo: nil) {
                pboard.writeObjects([url as NSURL])
            }
        }
        return true
    }
    
    
    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
            let text = self.textStorage!
            let length = text.length
            var effectiveRange = NSMakeRange(0, 0)
            
            while NSMaxRange(effectiveRange) < length {
                if let attachment = text.attribute(.attachment, at: NSMaxRange(effectiveRange), effectiveRange: &effectiveRange) as? NSTextAttachment {
                    if !(attachment.attachmentCell is URLAttachmentCell) {
                        if let filename = attachment.fileWrapper?.preferredFilename {
                            if filename.pathExtension == "url" &&
                                filename.deletingPathExtension.pathExtension == "meno" {
                                
                                let cell = URLAttachmentCell()
                                attachment.attachmentCell = cell
                            }
                        }
                    }
                }
            }
    }
    
//    func textView(_ textView: NSTextView, clickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
//        if let urlcell = cell as? URLAttachmentCell,
//           let data = urlcell.attachment?.fileWrapper?.regularFileContents {
//            let url = URL(dataRepresentation: data, relativeTo: nil)
//            self.selectingURL = url
//
//            if let panel = QLPreviewPanel.shared() {
//                panel.dataSource = self
//                panel.makeKeyAndOrderFront(self)
//            }
//        }
//    }
    func textView(_ textView: NSTextView, doubleClickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
        if let urlcell = cell as? URLAttachmentCell,
            let data = urlcell.attachment?.fileWrapper?.regularFileContents {
            let url = URL(dataRepresentation: data, relativeTo: nil)
            let ws = NSWorkspace.shared
            
            if let path = url?.path {
                ws.openFile(path)
            }
        }
    }
}

extension MTextView: QLPreviewPanelDataSource {
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return 1
    }
    
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return selectingURL! as NSURL
    }
    
}

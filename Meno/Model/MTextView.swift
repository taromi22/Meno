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
    var QLPanel: QLPreviewPanel?
    // 現在メニューを表示している可能性のあるCell (メニューを表示するときに対象のCellをこの変数に入れる)
    var possibleActiveCell: URLAttachmentCell?
    var previewingURL: NSURL?
    var controller: EditViewController!
    
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
    
    // このクラスでドラッグを処理すべきかどうか．そうでないときはスーパークラスに投げる
    func shouldHandleDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        let pboard = draggingInfo.draggingPasteboard()

        if pboard.availableType(from: [.fileURL]) == NSPasteboard.PasteboardType.fileURL {
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
                let relativeURL = URL(fileURLWithPath: url.path, relativeTo: self.controller.dbManager!.originURL!)
                
                if let path = relativeURL.path.removingPercentEncoding {
                    let cell = URLAttachmentCell()
                    
                    let textAttachment = NSTextAttachment(fileWrapper: self.fileWrapper(with: path, data: url.dataRepresentation))
                    cell.identifier = NSUserInterfaceItemIdentifier(path)
                    textAttachment.attachmentCell = cell

                    let cellstring = NSAttributedString(attachment: textAttachment)
                    storage.insert(cellstring, at: caretLocation)
                }
            }

            // 変更通知 (storageへの直接の追加は自動通知されない)
            self.didChangeText()
            
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
        return [.fileContents]
    }

    // 外にドラッグするときにちゃんとファイルURLをコピーしたい
    func textView(_ view: NSTextView, write cell: NSTextAttachmentCellProtocol, at charIndex: Int, to pboard: NSPasteboard, type: NSPasteboard.PasteboardType) -> Bool {
        if type == .fileURL {
            if let data = cell.attachment?.fileWrapper?.regularFileContents,
               let url = URL(dataRepresentation: data, relativeTo: nil) {
                pboard.writeObjects([url as NSURL])
                
                return true
            }
        }
        return false
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
    
    func textView(_ textView: NSTextView, clickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
        if let urlcell = cell as? URLAttachmentCell {
            
            self.possibleActiveCell = urlcell
            
            // Preview中ならPreviewの内容を切り替え，そうでなければメニューを表示
            if let qlPanel = self.QLPanel {
                if let data = urlcell.attachment?.fileWrapper?.regularFileContents {
                    self.previewingURL = NSURL(dataRepresentation: data, relativeTo: nil)
                    qlPanel.reloadData()
                }
            } else {
                let menu = NSMenu(title: "ファイルメニュー")
                menu.insertItem(withTitle: urlcell.stringValue, action: nil, keyEquivalent: "", at: 0)
                menu.insertItem(withTitle: "開く", action: #selector(openFileAction(sender:)), keyEquivalent: "", at: 1)
                menu.insertItem(withTitle: "Finderで表示", action: #selector(finderAction(sender:)), keyEquivalent: "", at: 2)
                menu.insertItem(withTitle: "QuickLook", action: #selector(QLAction(sender:)), keyEquivalent: " ", at: 3)
                
                menu.popUp(positioning: nil, at: NSMakePoint(cellFrame.origin.x, cellFrame.origin.y + cellFrame.height), in: self)
            }
        }
    }
    @objc func openFileAction(sender: Any) {
        if let urlcell = self.possibleActiveCell,
            let data = urlcell.attachment?.fileWrapper?.regularFileContents {
            
            let url = URL(dataRepresentation: data, relativeTo: nil)
            let ws = NSWorkspace.shared
            
            if let path = url?.path {
                ws.openFile(path)
            }
        }
    }
    @objc func finderAction(sender: Any) {
        if let cell = possibleActiveCell {
            let ws = NSWorkspace.shared
            let path = cell.stringValue
            ws.selectFile(path, inFileViewerRootedAtPath: "")
        }
    }
    @objc func QLAction(sender: Any) {
        
        if let urlcell = self.possibleActiveCell,
           let data = urlcell.attachment?.fileWrapper?.regularFileContents {
            
            self.previewingURL = NSURL(dataRepresentation: data, relativeTo: nil)
            
            if let panel = QLPreviewPanel.shared() {
                panel.makeKeyAndOrderFront(self)
                panel.dataSource = self
                panel.delegate = self
                
                self.QLPanel = panel
            }
        }
    }
}

extension MTextView: QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        if self.possibleActiveCell != nil {
            return 1
        } else {
            return 0
        }
    }
    
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        if let url = self.previewingURL {
            return url
        }
        return NSURL()
    }
    
    override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
        return true
    }
    
    override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        
    }
    override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        self.QLPanel = nil
    }
}

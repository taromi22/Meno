//
//  MTextView.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/20.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa
import Quartz

class MTextView: NSTextView {
    var QLPanel: QLPreviewPanel?
    /// 現在メニューを表示している可能性のあるCell (メニューを表示するときに対象のCellをこの変数に入れる)
    var possibleActiveURLCell: URLAttachmentCell?
    /// 現在QuickLookしているURL
    var previewingURL: NSURL?
    var controller: EditViewController!
    var originPath: String? {
        get {
            return self.controller.dbManager?.originPath
        }
    }
    
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
    
    /// 初期化時に呼ぶ
    func commonInit() {
        self.registerForDraggedTypes([.fileURL, NoteProfile.pasteboardTypeNoteProfile])
        self.delegate = self
        self.textStorage?.delegate = self
    }
    
    /// このクラスでドラッグを処理すべきか，スーパークラスに投げるか
    func shouldHandleDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        let pboard = draggingInfo.draggingPasteboard()

        if pboard.availableType(from: [.fileURL]) == NSPasteboard.PasteboardType.fileURL {
            return true
        }
        else if pboard.availableType(from: [NoteProfile.pasteboardTypeNoteProfile]) == NoteProfile.pasteboardTypeNoteProfile {
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
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return shouldHandleDrag(sender) ? [.link] : super.draggingUpdated(sender)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard()

        if !shouldHandleDrag(sender) {
            return super.performDragOperation(sender)
        }

        // ドロップされた位置を取得
        let dropPoint = self.convert(sender.draggingLocation(), from: nil)
        let caretLocation = self.characterIndexForInsertion(at: dropPoint)
        
        // ファイルがドロップされたとき
        if pboard.availableType(from: [.fileURL]) == NSPasteboard.PasteboardType.fileURL {
            if let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
                let storage = self.textStorage {
                
                for url in urls {
                    if let path = url.path.removingPercentEncoding {
                        
                        let cell = URLAttachmentCell(originPath: self.controller.dbManager!.originPath!)
                        
                        let relativePath = path.stringOfRelativePath(basePath: self.originPath!)
                        
                        let textAttachment = NSTextAttachment(fileWrapper: self.fileWrapperOfUrl(with: relativePath, data: Data()))
                        
                        textAttachment.attachmentCell = cell
                        let cellstring = NSAttributedString(attachment: textAttachment)
                        storage.insert(cellstring, at: caretLocation)
                    }
                }
                
                // 変更通知 (storageへの直接の追加は自動通知されない)
                self.didChangeText()
                
                return true
            }
        }
        // ノートのリストからドラッグされたとき
        else if pboard.availableType(from: [NoteProfile.pasteboardTypeNoteProfile]) == NoteProfile.pasteboardTypeNoteProfile {
            if let profiles = pboard.readObjects(forClasses: [NoteProfile.self], options: nil) as? [NoteProfile],
                let storage = self.textStorage {
                
                for profile in profiles {
                    let cell = NoteAttachmentCell()
                    let attachment = MTextAttachment(fileWrapper: self.fileWrapperOfProfile(with: String(profile.id), data: NSKeyedArchiver.archivedData(withRootObject: profile)))
                    
                    attachment.attachmentCell = cell
                    
                    let cellstring = NSAttributedString(attachment: attachment)
                    storage.insert(cellstring, at: caretLocation)
                }
                
                // 変更通知 (storageへの直接の追加は自動通知されない)
                self.didChangeText()
                
                return true
            }
        }
        return false
    }
    /// URLのAttachmentについてのFileWrapperを生成
    func fileWrapperOfUrl(with identifier: String, data: Data) -> FileWrapper {
        let wrapName = identifier.appendingPathExtension("meno")?.appendingPathExtension("url")
        let wrapper = FileWrapper(regularFileWithContents: data)
        
        wrapper.filename = wrapName
        wrapper.preferredFilename = wrapName
        
        return wrapper
    }
    /// ノートのAttachmentについてのFileWrapperを生成
    func fileWrapperOfProfile(with identifier: String, data: Data) -> FileWrapper {
        let wrapName = identifier.appendingPathExtension("meno")?.appendingPathExtension("profile")
        let wrapper = FileWrapper(regularFileWithContents: data)
        
        wrapper.filename = wrapName
        wrapper.preferredFilename = wrapName
        
        return wrapper
    }
    // [実装中] リスト上でエンターキーが押されたとき，次の行にリストを追加したい
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        
        if event.characters == "\r" {
            let list = NSTextList(markerFormat: NSTextList.MarkerFormat("{disc}"), options: 0)
            if let paragraph = self.typingAttributes[.paragraphStyle] as? NSParagraphStyle {
                print(paragraph.textLists.count)
            }
        }
    }
    /// TextView上のAttachmentのデータを更新．ファイルへのリンクの基準パスとノートへのリンクのプロファイルを更新．すでにカスタムCellに置き換えられている必要がある．
    func updateAttachments() {
        let text = self.textStorage!
        let length = text.length
        var effectiveRange = NSMakeRange(0, 0)
        
        while NSMaxRange(effectiveRange) < length {
            if let attachment = text.attribute(.attachment, at: NSMaxRange(effectiveRange), effectiveRange: &effectiveRange) as? NSTextAttachment {
                if let noteCell = attachment.attachmentCell as? NoteAttachmentCell {
                    //
                    // ノートへのリンクのProfileを更新
                    if let data = attachment.fileWrapper?.regularFileContents,
                       let oldProfile = NSKeyedUnarchiver.unarchiveObject(with: data) as? NoteProfile{
                        
                        let newProfile = self.controller.dbManager!.getProfile(id: oldProfile.id)
                        
                        if newProfile == nil {
                            continue
                        }
                        
                        attachment.fileWrapper = self.fileWrapperOfProfile(with: String(newProfile!.id), data: NSKeyedArchiver.archivedData(withRootObject: newProfile!))
                        noteCell.update()
                    }
                } else if let urlCell = attachment.attachmentCell as? URLAttachmentCell {
                    //  基準パスを更新
                    urlCell.originPath = self.originPath
                }
            }
        }
    }
    /// リンクを開くコマンド
    @objc func openFileAction(sender: Any) {
        if let urlcell = self.possibleActiveURLCell,
           let path = urlcell.stringValue.stringOfFullPath(basePath: self.originPath!) {
            
            let ws = NSWorkspace.shared
            
            ws.openFile(path)
        }
    }
    /// リンクをFinderで開くコマンド
    @objc func finderAction(sender: Any) {
        if let cell = possibleActiveURLCell {
            let ws = NSWorkspace.shared
            let path = cell.stringValue.stringOfFullPath(basePath: self.originPath!)
            ws.selectFile(path, inFileViewerRootedAtPath: "")
        }
    }
    /// リンクをQuickLookするコマンド
    @objc func QLAction(sender: Any) {
        
        if let urlcell = self.possibleActiveURLCell,
           let path = urlcell.stringValue.stringOfFullPath(basePath: self.originPath!) {
            
            self.previewingURL = NSURL(fileURLWithPath: path)
            
            if let panel = QLPreviewPanel.shared() {
                panel.makeKeyAndOrderFront(self)
                panel.dataSource = self
                panel.delegate = self
                
                
                self.QLPanel = panel
            }
        }
    }
    /// セルを削除するコマンド
    @objc func removeAction(sender: Any) {
        let text = self.textStorage!
        let length = text.length
        var effectiveRange = NSMakeRange(0, 0)
        
        if let selectedAttachment = self.possibleActiveURLCell?.attachment {
            while NSMaxRange(effectiveRange) < length {
                if let attachment = text.attribute(.attachment, at: NSMaxRange(effectiveRange), effectiveRange: &effectiveRange) as? NSTextAttachment {
                    if attachment === selectedAttachment {
                        text.replaceCharacters(in: effectiveRange, with: "")
                    }
                }
            }
        }
    }
}

extension MTextView: NSTextViewDelegate {
    func textView(_ view: NSTextView, writablePasteboardTypesFor cell: NSTextAttachmentCellProtocol, at charIndex: Int) -> [NSPasteboard.PasteboardType] {
        return [.fileContents]
    }
    func textView(_ view: NSTextView, write cell: NSTextAttachmentCellProtocol, at charIndex: Int, to pboard: NSPasteboard, type: NSPasteboard.PasteboardType) -> Bool {
        if let urlcell = cell as? URLAttachmentCell {
            
            if type == .fileContents {
                if let wrapper = urlcell.attachment?.fileWrapper {
                    pboard.write(wrapper)
                }
            }
            if type == .fileURL {
                if let path = urlcell.stringValue.stringOfFullPath(basePath: self.originPath!) {
                    let url = URL(fileURLWithPath: path)
                    pboard.writeObjects([url as NSURL])
                    
                    return true
                }
            }
        }
        return false
    }
    // NoteAttachmentをダブルクリックされたときにノートを移動する
    func textView(_ textView: NSTextView, doubleClickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
        if let noteCell = cell as? NoteAttachmentCell,
            let data = noteCell.attachment?.fileWrapper?.regularFileContents,
            let profile = NSKeyedUnarchiver.unarchiveObject(with: data) as? NoteProfile {
            
            let id = profile.id
            
            self.controller.itemsViewController.select(id: id)
        }
    }
    // URLAttachmentをクリックされたときにメニューを表示する
    func textView(_ textView: NSTextView, clickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
        if let urlcell = cell as? URLAttachmentCell {
            
            self.possibleActiveURLCell = urlcell
            
            // Preview中ならPreviewの内容を切り替え，そうでなければメニューを表示
            if let qlPanel = self.QLPanel {
                
                if let fullpath = urlcell.stringValue.stringOfFullPath(basePath: self.originPath!) {
                    self.previewingURL = NSURL(fileURLWithPath: fullpath)
                    qlPanel.reloadData()
                }
            } else {
                let menu = NSMenu(title: "ファイルメニュー")
                menu.insertItem(withTitle: urlcell.stringValue, action: nil, keyEquivalent: "", at: 0)
                menu.insertItem(withTitle: "開く", action: #selector(openFileAction(sender:)), keyEquivalent: "", at: 1)
                menu.insertItem(withTitle: "Finderで表示", action: #selector(finderAction(sender:)), keyEquivalent: "", at: 2)
                menu.insertItem(withTitle: "QuickLook", action: #selector(QLAction(sender:)), keyEquivalent: " ", at: 3)
                menu.insertItem(withTitle: "削除", action: #selector(removeAction(sender:)), keyEquivalent: "", at: 4)
                
                menu.popUp(positioning: nil, at: NSMakePoint(cellFrame.origin.x, cellFrame.origin.y + cellFrame.height), in: self)
            }
        }
    }
}

extension MTextView: NSTextStorageDelegate {
    // ドラッグドロップ，コピペなどでTextAttachmentのセルが標準のに戻ってしまったとき，それをカスタムセルに戻す
    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
        let text = self.textStorage!
        let length = text.length
        var effectiveRange = NSMakeRange(0, 0)
        
        while NSMaxRange(effectiveRange) < length {
            if let attachment = text.attribute(.attachment, at: NSMaxRange(effectiveRange), effectiveRange: &effectiveRange) as? NSTextAttachment {
                if !(attachment.attachmentCell is URLAttachmentCell || attachment.attachmentCell is NoteAttachmentCell) {
                    if let filename = attachment.fileWrapper?.preferredFilename {
                        if filename.pathExtension == "url" &&
                            filename.deletingPathExtension.pathExtension == "meno" {
                            
                            let cell = URLAttachmentCell(originPath: self.originPath!)
                            attachment.attachmentCell = cell
                        } else if filename.pathExtension == "profile" &&
                            filename.deletingPathExtension.pathExtension == "meno" {
                            
                            let cell = NoteAttachmentCell()
                            attachment.attachmentCell = cell
                        }
                    }
                }
            }
        }
    }
}

extension MTextView: QLPreviewPanelDataSource {
    
    // QLで表示するアイテムの数．複数は表示しないことにする
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        if self.possibleActiveURLCell != nil {
            return 1
        } else {
            return 0
        }
    }
    // 指定されたインデックスのURLを返す
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        if let url = self.previewingURL {
            return url
        }
        return nil
    }
    
    // 以下，QLのコントローラ関連
    // QLパネルのコントローラになるかどうかを返す
    override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
        return true
    }
    // QLパネルのコントロール開始
    override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        
    }
    // QLパネルのコントロール終了
    override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        self.QLPanel = nil
        self.previewingURL = nil
    }
}

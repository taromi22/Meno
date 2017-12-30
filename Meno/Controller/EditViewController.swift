//
//  EditViewController.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/15.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class EditViewController: NSViewController {
    
    var scrollView: NSScrollView!
    var contentView: EditView!
    var isModified: Bool = false
    
    var textView: MTextView! {
        get {
            return contentView.textView
        }
    }
    var titleField: NSTextField! {
        get {
            return contentView.titleField
        }
    }
    var dateField: NSTextField! {
        get {
            return contentView.dateField
        }
    }
    var dbManager: DBManager?
    var showingProfile: NoteProfile?
    var text: String {
        return self.textView.string
    }
    var textStorage: NSTextStorage? {
        return self.textView.textStorage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        scrollView = NSScrollView(frame: self.view.frame)
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autoresizingMask = [.width, .height]
        
        self.contentView = EditView(frame: NSMakeRect(0, 0, scrollView.contentSize.width, scrollView.contentSize.height))
        self.contentView.minSize = scrollView.contentSize
        self.contentView.autoresizingMask = [.width]
        self.contentView.delegate = self
        
        scrollView.documentView = contentView
        
        self.view.addSubview(scrollView)
    }
    
    func saveAndLoad(newProfile: NoteProfile) {
        // 保存処理
        if isModified, let oldProfile = self.showingProfile {
            dbManager!.saveProfile(profile: oldProfile)
            dbManager!.saveNote(id: oldProfile.id, content: self.textStorage!)
        }
        self.isModified = false
        // 表示
        let atrstring = dbManager!.getNote(id: newProfile.id)
        self.textStorage!.setAttributedString(atrstring ?? NSAttributedString())
        self.titleField.stringValue = newProfile.title
        self.showingProfile = newProfile
        self.dateField.stringValue = newProfile.updatedDate.description(with: Locale.current)
        // カーソルをトップへ　（一番上へスクロールさせるためのフラグとして用いている)
        self.textView.setSelectedRange(NSMakeRange(0, 0))
    }
}

extension EditViewController: EditViewDelegate {
    func editViewTitleChanged(string: String) {
        self.showingProfile?.title = self.titleField.stringValue
        self.isModified = true
        self.showingProfile?.updatedDate = Date()
        self.dateField.stringValue = self.showingProfile?.updatedDate.description(with: Locale.current) ?? ""
    }
    func editViewContentChanged() {
        self.isModified = true
        self.showingProfile?.updatedDate = Date()
        self.dateField.stringValue = self.showingProfile?.updatedDate.description(with: Locale.current) ?? ""
    }
}

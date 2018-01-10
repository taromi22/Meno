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
    var delegate: EditViewControllerDelegate?
    var fontManager: NSFontManager!
    var formatter: DateFormatter!
    var itemsViewController: ItemsViewController!
    
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
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        ValueTransformer.setValueTransformer(DateTransformerForTableView(), forName: .dateTransformerForTableView)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        ValueTransformer.setValueTransformer(DateTransformerForTableView(), forName: .dateTransformerForTableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        scrollView = NSScrollView(frame: self.view.frame)
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autoresizingMask = [.width, .height]
        
        self.contentView = EditView(frame: NSMakeRect(0, 0, scrollView.contentSize.width, scrollView.contentSize.height))
        self.contentView.controller = self
        self.contentView.minSize = NSMakeSize(0.0, scrollView.contentSize.height)
        self.contentView.autoresizingMask = [.width, .minYMargin]
        self.contentView.delegate = self
        
        scrollView.documentView = contentView
        
        self.formatter = DateFormatter()
        self.formatter.dateStyle = .long
        self.formatter.timeStyle = .short
        self.formatter.locale = Locale(identifier: "ja_JP")
        
        self.view.addSubview(scrollView)
    }
    ///
    /// 現在開いているノートを必要ならば保存したあと，指定されたノートを表示する
    ///
    func saveAndLoad(newProfile: NoteProfile) {
        // 保存処理
        if isModified, let oldProfile = self.showingProfile {
            dbManager!.saveProfile(profile: oldProfile)
            dbManager!.saveNote(id: oldProfile.id, content: self.textStorage!)
        }
        self.isModified = false
        
        // 新たなノートを表示
        if self.showingProfile !== newProfile {
            let atrstring = dbManager!.getNote(id: newProfile.id)
            self.textStorage!.setAttributedString(atrstring ?? NSAttributedString())
            self.titleField.stringValue = newProfile.title
            self.dateField.stringValue = self.formatter.string(from: newProfile.updatedDate)
            self.showingProfile = newProfile
            
            //  ノートへのリンクを更新
            self.contentView.textView.updateAttachments()
        }
    }
    // 現在開いているノートを必要ならば保存する．
    func save() {
        
        if isModified, let oldProfile = self.showingProfile {
            dbManager!.saveProfile(profile: oldProfile)
            dbManager!.saveNote(id: oldProfile.id, content: self.textStorage!)
        }
        self.isModified = false
    }
    ///
    /// 現在のノートに変更を加えたときに呼ぶ．
    ///
    func didChange() {
        self.isModified = true
        // 日時を更新
        let now = Date()
        self.showingProfile?.updatedDate = now
        
        self.dateField.stringValue = self.formatter.string(from: now)
        //
        self.delegate?.editViewControllerContentChanged()
    }
}

extension EditViewController: EditViewDelegate {
    func editViewTitleChanged(string: String) {
        self.showingProfile?.title = self.titleField.stringValue
        
        self.didChange()
    }
    func editViewContentChanged() {
        self.didChange()
    }
}

protocol EditViewControllerDelegate: class {
    func editViewControllerContentChanged()
}

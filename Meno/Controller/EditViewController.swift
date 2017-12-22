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
    var dbManager: DBManager?
    var showingId: Int?
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
        print(self.contentView.minSize)
        self.contentView.autoresizingMask = [.width]
        
        scrollView.documentView = contentView
        
        self.view.addSubview(scrollView)
    }
    
    func saveAndReload(id: Int) {
        // 保存処理
        if  let preId = self.showingId {
            dbManager!.saveNote(id: preId, content: self.textStorage!)
        }
        // 表示
        let atrstring = dbManager!.getNote(id: id)
        self.textStorage!.setAttributedString(atrstring ?? NSAttributedString())
        self.showingId = id
        // カーソルをトップへ　（一番上へスクロールさせるためのフラグとして用いている)
        self.textView.setSelectedRange(NSMakeRange(0, 0))
    }
}

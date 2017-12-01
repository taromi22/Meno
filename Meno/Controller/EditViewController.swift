//
//  EditViewController.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/15.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class EditViewController: NSViewController {
    
    @IBOutlet var textView: MTextView!
    
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
        
        textView.textContainerInset = NSSize(width: 20.0, height: 36.0)
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
    }
}

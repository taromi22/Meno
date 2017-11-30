//
//  Note.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/17.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class NoteProfile: NSObject {
    var id: Int
    var title: String
    var text: String
    var updatedDate: NSDate
    
    init(id: Int, title: String, text: String, date: NSDate) {
        self.id = id
        self.title = title
        self.text = text
        self.updatedDate = date
    }
}

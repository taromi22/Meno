//
//  Note.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/17.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//


import Cocoa

class NoteProfile: NSObject {
    @objc var id: Int
    @objc var title: String
    @objc var text: String
    @objc var updatedDate: NSDate
    
    @objc var titleForPresentation: String {
        get {
            if self.title == "" {
                return "タイトルなし"
            } else {
                return self.title
            }
        }
    }
    
    init(id: Int, title: String, text: String, date: NSDate) {
        self.id = id
        self.title = title
        self.text = text
        self.updatedDate = date
    }
}

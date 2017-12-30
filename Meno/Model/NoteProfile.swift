//
//  Note.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/17.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//


import Cocoa

class NoteProfile: NSObject {
    @objc var id: Int32
    @objc var title: String {
        //  titleForPresentationの変更通知を手動で呼ぶ
        willSet {
            self.willChangeValue(forKey: "titleForPresentation")
        }
        didSet {
            self.didChangeValue(forKey: "titleForPresentation")
        }
    }
    @objc var string: String
    @objc var updatedDate: Date
    @objc var createdDate: Date
    @objc var order: Int32
    @objc var titleForPresentation: String {
        get {
            if self.title == "" {
                return "タイトルなし"
            } else {
                return self.title
            }
        }
    }
    
    init(id: Int32, title: String, string: String, updatedDate: Date, createdDate: Date, order: Int32) {
        self.id = id
        self.title = title
        self.string = string
        self.updatedDate = updatedDate
        self.createdDate = createdDate
        self.order = order
    }
}

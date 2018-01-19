//
//  DBManager.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/17.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa
import FMDB

class DBManager: NSObject {
    var db: FMDatabase?
    private(set) var filePath: String?
    
    /// 開いているデータベースのフォルダの絶対パスを取得する．
    var originPath: String? {
        get {
            return self.filePath?.deletingLastPathComponent
        }
    }
    func create(url: URL) -> Bool {
        db = FMDatabase(url: url)
        
        let result = db!.open()
        
        if result {
            db!.executeUpdate("CREATE TABLE items (id integer auto_increment primary key, title text, content blob, string text, date_update text, date_create text, order_number integer)", withArgumentsIn: [])
        }
        
        return result
    }
    /// データベースファイルを開く
    func open(url: URL, completed: (Bool) -> Void) {
        db = FMDatabase(url: url)
        
        let result = db!.open()
        
        if result {
            self.filePath = url.path
        }
        completed(result)
    }
    // データベースをクローズする
    @discardableResult
    func close() -> Bool {
        return self.db?.close() ?? false
    }
    /// データベースファイルからすべてのNoteProfileを読み込む．
    func getProfiles() -> [NoteProfile]? {
        var profiles: [NoteProfile] = []
        
        // 失敗
        guard let results = db?.executeQuery("SELECT ID, TITLE, STRING, DATE_UPDATE, DATE_CREATE, ORDER_NUMBER FROM ITEMS", withParameterDictionary: nil) else {
            return nil
        }
        
        while results.next() {
            let title = results.string(forColumn: "TITLE") ?? ""
            let id = results.int(forColumn: "ID")
            let string = results.string(forColumn: "STRING") ?? ""
            let updatedDate = results.date(forColumn: "DATE_UPDATE") ?? Date()
            let createdDate = results.date(forColumn: "DATE_CREATE") ?? Date()
            let order = results.int(forColumn: "ORDER_NUMBER")
            
            profiles.append(NoteProfile(id: id, title: title, string: string, updatedDate: updatedDate, createdDate: createdDate, order: order))
        }
        
        return profiles
    }
    /// 指定したidをもつNoteProfileをデータベースファイルから読み込む．
    func getProfile(id: Int32) -> NoteProfile? {
        let results = db?.executeQuery("SELECT ID, TITLE, STRING, DATE_UPDATE, DATE_CREATE, ORDER_NUMBER FROM ITEMS WHERE ID=?", withArgumentsIn: [id])
        
        if let results = results {
            if !results.next() {
                return nil
            }
            
            let id = results.int(forColumn: "ID")
            let title = results.string(forColumn: "TITLE") ?? ""
            let string = results.string(forColumn: "STRING") ?? ""
            let updatedDate: Date = results.date(forColumn: "DATE_UPDATE") ?? Date()
            let createdDate: Date = results.date(forColumn: "DATE_CREATE") ?? Date()
            let order = results.int(forColumn: "ORDER_NUMBER")
            
            return NoteProfile(id: id, title: title, string: string, updatedDate: updatedDate, createdDate: createdDate, order: order)
        }
        
        return nil
    }
    /// データベースファイルにNoteProfileを上書き保存する．すでに存在するidをもつNoteProfileである必要がある．
    func saveProfile(profile: NoteProfile) {
        db!.executeUpdate("UPDATE ITEMS SET TITLE=?, STRING=?, DATE_UPDATE=?, DATE_CREATE=?, ORDER_NUMBER=? WHERE ID=?", withArgumentsIn: [profile.title, profile.string, profile.updatedDate as NSDate, profile.createdDate as NSDate, profile.order, profile.id])
    }
    /// 指定されたidをもつノートの内容をデータベースファイルから読み込む．
    func getNote(id: Int32) -> NSAttributedString? {
        let results = db?.executeQuery("SELECT CONTENT FROM ITEMS WHERE ID=\(id)", withParameterDictionary: nil)
        
        if let results = results {
            results.next()
            if let data = results.data(forColumn: "CONTENT") {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? NSAttributedString
            } else {
                return nil
            }
        }
        
        return nil
    }
    /// データベースファイルにノートの内容を保存する．すでに存在するノートのidである必要がある．
    @discardableResult
    func saveNote(id: Int32, content: NSAttributedString) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: content)
        
        return db!.executeUpdate("UPDATE ITEMS SET CONTENT=? WHERE ID=\(id)", withArgumentsIn: [data])
    }
    /// 新たなノートを作成する．
    // - returns: 新規作成したノートのid．失敗ならnil．
    func addNew() -> Int32? {
        if db!.executeUpdate("INSERT INTO ITEMS(TITLE, CONTENT, STRING, DATE_UPDATE, DATE_CREATE) VALUES(?, ?, ?, ?, ?)", withArgumentsIn: ["", NSKeyedArchiver.archivedData(withRootObject: NSAttributedString()), "", NSDate(), NSDate()]) {
            let results = db!.executeQuery("SELECT ID FROM ITEMS WHERE ROWID = last_insert_rowid()", withParameterDictionary: nil)
            if let results = results {
                results.next()
                return results.int(forColumn: "ID")
            }
        }
        return nil
    }
    // ノートを削除する．
    // - returns: 成功ならTrue
    func removeItem(id: Int32) -> Bool {
        return db!.executeUpdate("DELETE FROM ITEMS WHERE ID = \(id)", withParameterDictionary: [:])
    }
}

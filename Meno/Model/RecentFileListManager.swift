//
//  RecentFileListManager.swift
//  Meno
//
//  Created by 柳谷太郎 on 2018/01/12.
//  Copyright © 2018年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class RecentFileListManager: NSObject {
    static func readPaths() -> [String] {
        let ud = UserDefaults.standard
        
        guard let array = ud.array(forKey: "recentFiles") as? [String] else {
            let altData = [String]()
            ud.set(NSArray(array: altData), forKey: "recentFiles")
            return altData
        }
        
        return array
    }
    static func addPath(path: String) {
        let ud = UserDefaults.standard
        
        guard var paths = ud.array(forKey: "recentFiles") as? [String] else {
            let altData = [path]
            ud.set(altData, forKey: "recentFiles")
            
            return
        }
        
        if !paths.contains(path) {
            paths.insert(path, at: 0)
            
            ud.set(paths, forKey: "recentFiles")
        }
    }
    static func removePath(path: String) {
        let ud = UserDefaults.standard
        
        guard var paths = ud.array(forKey: "recentFiles") as? [String] else {
            return
        }
        
        for (i, p) in paths.enumerated() {
            if p == path {
                paths.remove(at: i)
            }
        }
        
        ud.set(paths, forKey: "recentFiles")
    }
}

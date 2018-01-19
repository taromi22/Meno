//
//  URLTableView.swift
//  Meno
//
//  Created by 柳谷太郎 on 2018/01/17.
//  Copyright © 2018年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class URLTableView: NSTableView {
    
    var actionTarget: AnyObject?

    override func menu(for event: NSEvent) -> NSMenu? {
        let menu = NSMenu(title: "URLTableViewPopUpMenu")
        let deleteMenuItem = NSMenuItem(title: "削除", action: #selector(WelcomeViewController.deleteRecentFileItemAction(_:)), keyEquivalent: "delete")
        
        deleteMenuItem.target = self.actionTarget
        
        menu.addItem(deleteMenuItem)
        
        return menu
    }
    
}

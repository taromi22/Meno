//
//  WIndowController.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/14.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa
import FMDB

class WindowController: NSWindowController, ItemsViewControllerDelegate {
    var dbManager: DBManager?
    
    var splitViewController: SplitViewController! {
        return self.contentViewController as? SplitViewController
    }
    var titlesViewController: ItemsViewController! {
        return splitViewController?.titlesViewController
    }
    var editViewController: EditViewController! {
        return splitViewController?.editViewController
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    
        if let window = window, let screen = window.screen {
            let screenRect = screen.visibleFrame
            let newOriginY = screenRect.maxY - window.frame.height - LWinY
            window.setFrameOrigin(NSPoint(x: LWinX, y: newOriginY))
            window.setContentSize(LWinSize)
            window.title = LWinTitle
        }
        
        dbManager = DBManager()
        editViewController.dbManager = dbManager
        
        titlesViewController.delegate = self
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        
        openPanel.beginSheetModal(for: self.window!) {
            (response) -> Void in
            
            if response == .OK {
                let url = openPanel.url!
                
                self.dbManager?.open(url: url) { (result) in
                    self.titlesViewController.setItems((self.dbManager?.getProfile())!)
                }
            }
        }
    }
    
    func itemsViewControllerSelectionChanged(newProfile: NoteProfile?, oldProfile: inout NoteProfile?) {
        
        if let profile = newProfile {
            editViewController.saveAndLoad(newProfile: profile)
        }
        if let old = oldProfile {
            oldProfile = dbManager?.getProfile(id: old.id)
        }
    }

    @IBAction func addAction(_ sender: Any) {
        if let id = dbManager!.addNew() {
            titlesViewController.addItem(NoteProfile(id: id, title: "", text: "", date: NSDate()))
            self.window!.makeFirstResponder(self.editViewController!.textView)
        }
    }
    @IBAction func removeAction(_ sender: Any) {
        if let profile = titlesViewController.selectedProfile {
            if dbManager!.removeItem(id: profile.id) {
                self.titlesViewController.removeSelectedItem()
            }
        }
    }
    @IBAction func getAttributesAction(_ sender: Any) {
        var range = NSRange(location: 0, length: self.editViewController.textStorage!.length)
        let dic = self.editViewController.textStorage?.attributes(at: self.editViewController.textView.selectedRange().location, effectiveRange: &range)
        
        print(dic)
    }
}

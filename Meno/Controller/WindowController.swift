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
    @IBOutlet weak var boldButton: NSButton!
    @IBOutlet weak var italicButton: NSButton!
    @IBOutlet weak var underlineButton: NSButton!
    
    var dbManager: DBManager!
    var attributeObserver: TextViewAttributeObserver!
    var paragraphMenu: ParagraphMenu!
    
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
        editViewController.delegate = self
        
        self.paragraphMenu = ParagraphMenu(title: "段落")
        
        attributeObserver = TextViewAttributeObserver()
        attributeObserver.boldButton = self.boldButton
        attributeObserver.italicButton = self.italicButton
        attributeObserver.underlineButton = self.underlineButton
        attributeObserver.targetTextView = self.editViewController.contentView.textView
        attributeObserver.paragraphMenu = self.paragraphMenu
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
                    if !result { return }
                    
                    self.window!.title = url.path
                    
                    if let profiles = self.dbManager?.getProfile() {
                        self.titlesViewController.setItems(profiles, didSet: {
                            // 項目の準備ができ，一番上の項目が選択され，内容の表示まで終わったとき
                            self.window?.makeFirstResponder(self.editViewController.contentView.textView)
                        })
                    }
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
            let profile = NoteProfile(id: id, title: "", string: "", updatedDate: Date(), createdDate: Date(), order: 0)
            titlesViewController.addItem(profile)
            dbManager!.saveProfile(profile: profile)
            self.window!.makeFirstResponder(self.editViewController.titleField)
        }
    }
    @IBAction func removeAction(_ sender: Any) {
        if let profile = titlesViewController.selectedProfile {
            if dbManager!.removeItem(id: profile.id) {
                self.titlesViewController.removeSelectedItem()
            }
        }
    }
    @IBAction func openParagraphMenuAction(_ sender: Any) {
        if let button = sender as? NSButton {
            let point = NSMakePoint(button.frame.origin.x, button.frame.origin.y + button.frame.height)
            
            self.paragraphMenu.popUp(positioning: nil, at: point, in: button)
        }
    }
}

extension WindowController: EditViewControllerDelegate {
    func editViewControllerContentChanged() {
        self.titlesViewController.raiseSelectedItem()
    }
}

//
//  WIndowController.swift
//  Meno
//
//  Created by 柳谷太郎 on 2017/11/14.
//  Copyright © 2017年 Taro Yanagiya. All rights reserved.
//

import Cocoa
import FMDB

class WindowController: NSWindowController {
    @IBOutlet weak var boldButton: NSButton!
    @IBOutlet weak var italicButton: NSButton!
    @IBOutlet weak var underlineButton: NSButton!
    
    var dbManager: DBManager!
    var transitionManager: NoteTransitionManager = NoteTransitionManager()
    var attributeObserver: TextViewAttributeObserver!
    var paragraphMenu: ParagraphMenu!
    var welcomeViewController: WelcomeViewController?
    
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
            window.contentMinSize = LWinMinSize
            window.setContentSize(LWinSize)
            window.title = LWinTitle
            window.delegate = self
        }
        
        self.dbManager = DBManager()
        self.editViewController.dbManager = self.dbManager
        self.editViewController.transitionManager = self.transitionManager
        self.titlesViewController.transitionManager = self.transitionManager
        
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
        
        showWelcomeView()
    }
    
    ///WelcomeViewでユーザが操作をした時
    func welcomeViewUserOperated(response: WelcomeViewController.Response) {
        self.splitViewController.dismissViewController(self.welcomeViewController!)
        
        if response == .openOther {
            self.openAction()
        } else if response == .openFromRecentFiles {
            let url = self.welcomeViewController!.selectedURL!
            
            // ファイルが存在しない時の処理
            let fm = FileManager.default
            if !fm.fileExists(atPath: url.path) {
                let alert = NSAlert()
                alert.messageText = "ファイルが存在しません"
                alert.informativeText = "最近開いたファイルリストから削除しますか？"
                alert.addButton(withTitle: "はい")
                alert.addButton(withTitle: "いいえ")
                alert.alertStyle = .critical
                let res_alert = alert.runModal()
                
                if res_alert == .alertFirstButtonReturn {
                    RecentFileListManager.removePath(path: url.path)
                }
                
                // もう一度WelcomeViewを表示
                self.showWelcomeView()
                return
            }
            
            self.openDB(url: url)
        } else if response == .newFile {
            self.newFileAction()
        }
        
        
        self.welcomeViewController = nil
    }
    /// 「開く」アクション
    func openAction() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        
        openPanel.beginSheetModal(for: self.window!) {
            (response) -> Void in
            
            if response == .OK {
                let url = openPanel.url!
                
                self.openDB(url: url)
            } else {
                // キャンセルがクリックされた場合はもう一度welcomeViewを表示する
                self.showWelcomeView()
            }
        }
    }
    func newFileAction() {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.allowedFileTypes = ["meno"]
        
        savePanel.beginSheetModal(for: self.window!) { (response) in
            if response == .OK {
                self.createDB(url: savePanel.url!)
            } else {
                self.showWelcomeView()
            }
        }
    }
    /// DBManagerを用いて指定されたURLのデータベースを開き、読みこむ。
    func openDB(url: URL) {
        self.dbManager!.open(url: url) { (result) in
            // 失敗
            if !result {
                let alert = NSAlert()
                alert.messageText = "エラーが発生しました"
                alert.informativeText = "読み込めないファイル形式である可能性があります。"
                alert.addButton(withTitle: "OK")
                alert.alertStyle = .critical
                alert.runModal()
                
                self.showWelcomeView() // もう一度WelcomeViewを表示する
                
                return
            }
            // ノート一覧を読み込み
            guard let profiles = self.dbManager!.getProfiles() else {
                let alert = NSAlert()
                alert.messageText = "エラーが発生しました"
                alert.informativeText = "読み込めないファイル形式です。"
                alert.addButton(withTitle: "OK")
                alert.alertStyle = .critical
                alert.runModal()
                
                self.showWelcomeView()
                
                return
            }
            
            // 以下成功
            self.window!.title = url.path
            
            RecentFileListManager.addPath(path: url.path)
            
            self.titlesViewController.setItems(profiles, didSet: {
                // 項目の準備ができ，一番上の項目が選択され，内容の表示まで終わったとき
                self.window?.makeFirstResponder(self.editViewController.contentView.textView)
            })
        }
    }
    
    func createDB(url: URL) {
        let fm = FileManager.default
        
        if fm.fileExists(atPath: url.path) {
            try? fm.removeItem(at: url)
        }
        
        let result = self.dbManager.create(url: url)
        
        // 作成に失敗
        if !result {
            let alert = NSAlert()
            alert.messageText = "エラーが発生しました"
            alert.informativeText = "データベースファイルの作成に失敗しました。"
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .critical
            alert.runModal()
            
            // もう一度ファイル保存ダイアログ表示
            self.newFileAction()
            return
        }
        
        // 以下成功
        self.window!.title = url.path
        
        RecentFileListManager.addPath(path: url.path)
        
        if let id = dbManager.addNew(),
            let profile = dbManager.getProfile(id: id) {
            self.titlesViewController.addItem(profile)
        }
        
        self.window!.makeFirstResponder(self.editViewController.titleField)
    }
    
    func showWelcomeView() {
        
        // xibファイルからViewControllerを読みこむ
        self.welcomeViewController = WelcomeViewController(nibName: NSNib.Name(rawValue: "WelcomeViewController"), bundle: nil)
        
        self.welcomeViewController!.userOperated = self.welcomeViewUserOperated
        
        self.welcomeViewController!.setPaths(paths: RecentFileListManager.readPaths())
        self.splitViewController.presentViewControllerAsSheet(self.welcomeViewController!)
    }

    @IBAction func addAction(_ sender: Any) {
        if let id = dbManager.addNew(),
            let profile = dbManager.getProfile(id: id) {
            titlesViewController.addItem(profile)
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

extension WindowController: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        self.editViewController.save()
        
        return true
    }
}

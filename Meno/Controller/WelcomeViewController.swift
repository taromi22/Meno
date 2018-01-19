//
//  WelcomeViewController.swift
//  Meno
//
//  Created by 柳谷太郎 on 2018/01/12.
//  Copyright © 2018年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class WelcomeViewController: NSViewController {
    
    @IBOutlet weak var urlsTableView: URLTableView!
    
    var selectedURL: URL?
    var userOperated: ((Response) -> ())?
    
    private var paths = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.urlsTableView.delegate = self
        self.urlsTableView.dataSource = self
        self.urlsTableView.actionTarget = self
        self.urlsTableView.doubleAction = #selector(self.tableViewDoubleClicked)
    }
    
    /// 最近開いたファイルリストに表示するURLを設定する。
    func setPaths(paths: [String]) {
        self.paths = paths
        
        if urlsTableView != nil {
            self.urlsTableView.reloadData()
        }
    }
    
    @IBAction func newAction(_ sender: Any) {
        self.userOperated?(.newFile)
    }
    
    @IBAction func openOtherAction(_ sender: Any) {
        self.userOperated?(.openOther)
    }
    
    @objc func deleteRecentFileItemAction(_ sender: Any) {
        let deletingPath = self.paths.remove(at: self.urlsTableView.selectedRow)
        
        RecentFileListManager.removePath(path: deletingPath)
        
        self.urlsTableView.reloadData()
    }
    
    @objc func tableViewDoubleClicked() {
        let path = self.paths[self.urlsTableView.selectedRow]
        
        self.selectedURL = URL(fileURLWithPath: path)
        self.userOperated?(.openFromRecentFiles)
    }
    
    enum Response {
        case openOther
        case openFromRecentFiles
        case newFile
    }
}

extension WelcomeViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.paths.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return self.paths[row]
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        cellView.textField?.stringValue = self.paths[row]
        return cellView
    }
}

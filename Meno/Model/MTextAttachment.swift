//
//  MTextAttachment.swift
//  Meno
//
//  Created by 柳谷太郎 on 2018/01/07.
//  Copyright © 2018年 Taro Yanagiya. All rights reserved.
//

import Cocoa

class MTextAttachment: NSTextAttachment {
    // Attachmentの位置がベースライン上になってしまい，文字に比べて上方に表示されるため，位置を下に下げたい．がなぜか呼ばれない・・・
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: NSRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> NSRect {
        let font = NSFont.systemFont(ofSize: 13)
        var bounds = CGRect()
        bounds.origin = CGPoint(x: 0, y: font.descender)
        bounds.size = self.attachmentCell?.cellSize() ?? CGSize(width: 0, height: 0)
        
        return bounds
    }
}

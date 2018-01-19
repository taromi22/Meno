//
//  UIResponderExtension.swift
//  Meno
//
//  Created by 柳谷太郎 on 2018/01/19.
//  Copyright © 2018年 Taro Yanagiya. All rights reserved.
//

import Foundation
import Cocoa

extension NSResponder {
    func nextResponder<T>() -> T? {
        guard let responder = self.nextResponder else {
            return nil
        }
        
        return (responder as? T) ?? responder.nextResponder()
    }
}

//
//  Extension.swift
//  LunarCore-Swift
//
//  Created by Elors on 2016/11/7.
//  Copyright © 2016年 elors. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return (0..<count).contains(index) ? self[index] : nil
    }
}

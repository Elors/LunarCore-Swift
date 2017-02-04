//
//  LCMemoryCache.swift
//  LunarCore-Swift
//
//  Created by 王新宇 on 2017/2/3.
//  Copyright © 2017年 elors. All rights reserved.
//

import Cocoa

/**
 *  缓存 主要是缓存节气信息
 */
public class LCMemoryCache: NSObject {
    
    var current: Int? {
        didSet {
            clear()
        }
    }
    var cache: [String: Any?]
    
    
    override init() {
        cache = [String: Any?]()
        super.init()
    }
    
    public func get(key: String) -> Any? {
        let a = cache[key] ?? nil
        return a
    }
    
    public func setKey(_ key: String, Value value: Any?) {
        cache[key] = value
    }
    
    private func clear() {
        cache.removeAll()
    }
}

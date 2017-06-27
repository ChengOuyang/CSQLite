//
//  CSQLiteConfig.swift
//  CSQLite
//
//  Created by yanwei on 17/6/26.
//  Copyright © 2017年 clou. All rights reserved.
//

import UIKit

public enum CSQLiteSynchronousMode: String {
    case normal
    case off
}

extension CSQLiteSynchronousMode: CustomStringConvertible {
    
    public var description: String {
        return self.rawValue.uppercased()
    }
}

public enum CSQLiteJournalMode: String {
    case normal
    case off
    case memory
}

extension CSQLiteJournalMode: CustomStringConvertible {
    
    public var description: String {
        return self.rawValue.uppercased()
    }
}

public struct CSQLiteConfig: CustomStringConvertible {
    
    /// 页大小
    public var pageSize = UInt32(4096)
    
    /// 缓存大小,默认2MB
    public var cacheSize = Int32(-2000)
    
    /// WAL模式下提交的阀值
    public var walAutoCheckPoint = UInt32(1000)
    
    /// 日志存储模式
    var journalMode = CSQLiteJournalMode.normal
    
    /// 文件同步模式
    var synchronousMode = CSQLiteSynchronousMode.normal
    
    public var description: String {
        return "配置信息：\npageSize = \(pageSize)\ncacheSize = \(cacheSize)\nwalAutoCheckPoint = \(walAutoCheckPoint)\njournalMode = \(journalMode.description)\nsynchronousMode = \(synchronousMode.description)\n"
    }
    
}

//
//  CRunResult.swift
//  CSQLite
//
//  Created by yanwei on 17/6/23.
//  Copyright © 2017年 clou. All rights reserved.
//

import UIKit

public struct CRunResult: CustomStringConvertible {
    
    /// 串行插入耗时
    public var serialInsertTime = Double(0)
    
    /// 并行插入耗时
    public var concurrentInsertTime = Double(0)
    
    /// 串行查寻耗时
    public var serialQueryTime = Double(0)
    
    /// 并行查寻耗时
    public var concurrentQueryTime = Double(0)
    
    /// 串行插入耗时（使用事务）
    public var serialInsertTimeInTransaction = Double(0)
    
    /// 并行插入耗时（使用事务）
    public var concurrentInsertTimeInTransaction = Double(0)
    
    /// 串行查寻耗时（使用事务）
    public var serialQueryTimeInTransaction = Double(0)
    
    /// 并行查寻耗时（使用事务）
    public var concurrentQueryTimeInTransaction = Double(0)
    
    public var description: String {
        return "运行结果：\n非事务情况：\n串行插入耗时 \(serialInsertTime) 秒.\n并行插入耗时 \(concurrentInsertTime) 秒.\n串行查寻耗时 \(serialQueryTime) 秒.\n并行查寻耗时 \(concurrentQueryTime) 秒.\n事务情况：\n串行插入耗时 \(serialInsertTimeInTransaction) 秒.\n并行插入耗时 \(concurrentInsertTimeInTransaction) 秒.\n串行查寻耗时 \(serialQueryTimeInTransaction) 秒.\n并行查寻耗时 \(concurrentQueryTimeInTransaction) 秒."
    }
}

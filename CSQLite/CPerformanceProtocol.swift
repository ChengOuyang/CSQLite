//
//  CPerformanceProtocol.swift
//  CSQLite
//
//  Created by yanwei on 17/6/23.
//  Copyright © 2017年 clou. All rights reserved.
//

import UIKit

public protocol CSQLite3PerformanceProtocol: CPerformanceProtocol {
    
    /// 数据库连接对象
    var sqlites: [CSQLite] { get set }
    
    /// SQL VDBE 语句复用
    var reuse: Bool { get set }
}

extension CSQLite3PerformanceProtocol {
    
    public func serialInsert() -> Double {
        print("开始串行插入数据.")
        let numOfRows = row / concurrentCount
        var cost = Double(0)
        for (_, sqlite) in sqlites.enumerated() {
            let duration = calculatCostTime {
                self.sqlOperation(sqlite: sqlite, operation: {
                    if !sqlite.insert(row: numOfRows, reuse: self.reuse) {
                        cost = -1
                        print("插入失败: ", sqlite.lastErrorMessage())
                    }
                })
            }
            if cost != -1 {
                cost += duration
            } else {
                break
            }
        }
        print("完成串行插入数据.")
        return cost
    }
    
    public func concurrentInsert() -> Double {
        print("开始并行插入数据.")
        let numOfRows = row / concurrentCount
        var cost = Double(0)
        let group = DispatchGroup()
        for (_, sqlite) in sqlites.enumerated() {
            group.enter()
            DispatchQueue.global().async {
                let duration = calculatCostTime {
                    self.sqlOperation(sqlite: sqlite, operation: {
                        if !sqlite.insert(row: numOfRows, reuse: self.reuse) {
                            objc_sync_enter(cost)
                            cost = -1
                            objc_sync_exit(cost)
                        }
                    })
                }
                // 对 cost 进行操作加锁
                objc_sync_enter(cost)
                if cost != -1 {
                    cost = (cost > duration) ? cost : duration
                }
                objc_sync_exit(cost)
                group.leave()
            }
        }
        group.wait()
        print("完成并行插入数据.")
        return cost
    }
    
    public func serialQuery() -> Double {
        print("开始串行查寻数据.")
        let numOfRows = row / concurrentCount
        var cost = Double(0)
        for (_, sqlite) in sqlites.enumerated() {
            let duration = calculatCostTime {
                self.sqlOperation(sqlite: sqlite, operation: {
                    if !sqlite.query(limit: numOfRows, offset: 0) {
                        cost = -1
                    }
                })
            }
            if cost != -1 {
                cost += duration
            }
        }
        print("完成串行查寻数据.")
        return cost
    }
    
    public func concurrentQuery() -> Double {
        print("开始并行查寻数据.")
        let numOfRows = row / concurrentCount
        var cost = Double(0)
        let group = DispatchGroup()
        for (index, sqlite) in sqlites.enumerated() {
            print("并行查寻", index)
            group.enter()
            DispatchQueue.global().async {
                let duration = calculatCostTime {
                    self.sqlOperation(sqlite: sqlite, operation: {
                        if !sqlite.query(limit: numOfRows, offset: numOfRows * index) {
                            objc_sync_enter(cost)
                            cost = -1
                            objc_sync_exit(cost)
                        }
                    })
                }
                // 对 cost 进行操作加锁
                objc_sync_enter(cost)
                if cost != -1 {
                    cost = (cost > duration) ? cost : duration
                }
                objc_sync_exit(cost)
                group.leave()
            }
        }
        group.wait()
        print("完成并行查寻数据.")
        return cost
    }
    
    public func sqlOperation(sqlite: CSQLite , operation: Function) {
        if isTransaction {
            sqlite.beginTransaction()
            operation()
            sqlite.commit()
        } else {
            operation()
        }
    }
    
    public func rowsOfTable() -> Int64 {
        return sqlites.reduce(0, {$0 + $1.rows()})
    }
}

public protocol CPerformanceProtocol: NSObjectProtocol {
    
    /// 单次查寻条目数量
    var row: Int { get set }
    
    /// 并发次数
    var concurrentCount: Int { get set }
    
    /// 是否使用事务
    var isTransaction: Bool { get set }
    
    /// 运行结果
    var result: CRunResult { get set }
    
    /// 初始化
    func setup()
    
    /// 串行查寻耗费时间
    func serialQuery() -> Double
    /// 并行查寻耗费时间
    func concurrentQuery() -> Double
    /// 串行插入耗费时间
    func serialInsert() -> Double
    /// 并行插入耗费时间
    func concurrentInsert() -> Double
    
    /// 运行
    func run()
}

public extension CPerformanceProtocol {
    
    func run() {
        setup()
        isTransaction = false
        result.serialInsertTime = serialInsert()
        result.concurrentInsertTime = concurrentInsert()
        result.serialQueryTime = serialQuery()
        result.concurrentQueryTime = concurrentQuery()
        isTransaction = true
        result.serialInsertTimeInTransaction = serialInsert()
        result.concurrentInsertTimeInTransaction = concurrentInsert()
        result.serialQueryTimeInTransaction = serialQuery()
        result.concurrentQueryTimeInTransaction = concurrentQuery()
        print(result)
    }
}

//
//  CSingleDbViewModel.swift
//  CSQLite
//
//  Created by yanwei on 17/6/23.
//  Copyright © 2017年 clou. All rights reserved.
//

import UIKit

// MARK: - 外部接口
extension CSingleDbViewModel {

}

public class CSingleDbViewModel: NSObject, CSQLite3PerformanceProtocol {
    
    public var sqlites = [CSQLite]()
    
    public var config = CSQLiteConfig()
    
    public var reuse: Bool = true
    
    public var row: Int = 1000 {
        didSet {
            guard row % concurrentCount != 0 else { return }
            row = 1000
        }
    }
    
    public var concurrentCount: Int = 2 {
        didSet {
            guard concurrentCount != 1 && concurrentCount % 2 != 0 else { return }
            concurrentCount = 2
        }
    }
    
    public var isTransaction: Bool = false
    
    public var result: CRunResult = CRunResult()
    
    public func setup() {
        sqlites.removeAll()
        concurrentCount = 1
        let sqlite = CSQLite(fileName: "single.db", tableName: "csqlite", config: config)
        sqlites.append(sqlite)
    }
    
    public func concurrentInsert() -> Double {
        print("无法对同一个数据库连接进行多线程操作.")
        return -1
    }
    
    public func serialQuery() -> Double {
        guard sqlites.count == 1 else { return -1 }
        print("开始串行查寻数据.")
        let sqlite = sqlites[0]
        let cost = calculatCostTime {
            self.sqlOperation(sqlite: sqlite, operation: {
                sqlite.query(limit: row, offset: 0)
            })
        }
        print("完成串行查寻数据.")
        return cost
    }
    
    public func concurrentQuery() -> Double {
        print("无法对同一个数据库连接进行多线程操作.")
        return -1
    }
}

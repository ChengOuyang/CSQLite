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
        let sqlite = CSQLite(fileName: "single.db", tableName: "csqlite")
        sqlites.append(sqlite)
    }
    
    public func concurrentInsert() -> Double {
        print("无法对同一个表进行并行插入.")
        return -1
    }
    
    public func concurrentQuery() -> Double {
        guard sqlites.count == 1 else { return -1 }
        print("开始并行查寻数据.")
        let sqlite = sqlites[0]
        var cost = Double(0)
        let numOfRow = row / concurrentCount
        let group = DispatchGroup()
        for index in 0..<concurrentCount {
            group.enter()
            DispatchQueue.global().async {
                let duration = calculatCostTime {
                    self.sqlOperation(sqlite: sqlite, operation: {
                        sqlite.query(limit: numOfRow, offset: numOfRow * index)
                    })
                }
                // 对 cost 进行操作加锁
                objc_sync_enter(cost)
                cost = (cost > duration) ? cost : duration
                objc_sync_exit(cost)
                group.leave()
            }
        }
        group.wait()
        print("完成并行插入数据.")
        return cost
    }
}

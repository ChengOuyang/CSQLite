//
//  CMulLinkViewModel.swift
//  CSQLite
//
//  Created by yanwei on 17/6/26.
//  Copyright © 2017年 clou. All rights reserved.
//

import UIKit

public class CMulLinkViewModel: NSObject, CSQLite3PerformanceProtocol {
    
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
        for _ in 0..<concurrentCount {
            let sqlite = CSQLite(fileName: "mulTable.db", tableName: "test")
            sqlites.append(sqlite)
        }
    }
    
    public func concurrentInsert() -> Double {
        print("无法对同一张表并行写入.")
        return -1
    }
}

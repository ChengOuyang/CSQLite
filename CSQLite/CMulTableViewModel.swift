//
//  CMulTableViewModel.swift
//  CSQLite
//
//  Created by yanwei on 17/6/23.
//  Copyright © 2017年 clou. All rights reserved.
//

import UIKit

public class CMulTableViewModel: NSObject, CSQLite3PerformanceProtocol {
    
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
        for index in 0..<concurrentCount {
            let sqlite = CSQLite(fileName: "mulTable.db", tableName: "table\(index)", config: config)
            sqlites.append(sqlite)
        }
    }
}

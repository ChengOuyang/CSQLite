//
//  CMulDbViewModel.swift
//  CSQLite
//
//  Created by yanwei on 17/6/23.
//  Copyright © 2017年 clou. All rights reserved.
//

import UIKit

/// 数据库测试模式
enum CDBTestMode {
    case common
}

// MARK: - 外部接口
extension CMulDbViewModel {

}

/// 多个数据库普通模式下测试
public class CMulDbViewModel: NSObject, CSQLite3PerformanceProtocol {
    
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
        for index in 0..<concurrentCount {
            let sqlite = CSQLite(fileName: "mulTable\(index).db", tableName: "test")
            sqlites.append(sqlite)
        }
    }
}

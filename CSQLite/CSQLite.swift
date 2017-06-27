//
//  CSQLite.swift
//  CSQLite
//
//  Created by yanwei on 17/6/22.
//  Copyright © 2017年 clou. All rights reserved.
//

import UIKit

// MARK: - 外部接口
extension CSQLite {
    

}

public class CSQLite {
    
    /// 数据库磁盘保存路径
    public var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    /// 数据库文件名字
    public var fileName = "sqlite.db"
    
    /// 数据表名
    public var tableName = "csqlite"
    
    /// 数据库连接
    public var db: OpaquePointer? = nil
    
    /// 数据库配置
    public var config = CSQLiteConfig()
    
    /// 数据库文件路径
    fileprivate var dbPath: UnsafePointer<Int8> {
        return NSString(string: path + "/" + fileName).fileSystemRepresentation
    }
    
    fileprivate let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    fileprivate let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    public init() {
        setup()
    }
    
    public init(fileName: String, tableName: String, config: CSQLiteConfig) {
        self.fileName = fileName
        self.tableName = tableName
        self.config = config
        setup()
    }
    
    public init(path: String, fileName: String, tableName: String, config: CSQLiteConfig) {
        self.path = path
        self.fileName = fileName
        self.tableName = tableName
        self.config = config
        setup()
    }
    
    deinit {
        print("关闭数据库 \(fileName).")
        sqlite3_close_v2(db)
    }
    
    fileprivate func setup() {

        print("path = ", path)
        
        if sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_NOMUTEX | SQLITE_OPEN_PRIVATECACHE, nil) == SQLITE_OK {
            print("打开数据库 \(fileName) 成功.")
        } else {
            print("打开数据库失败：", lastErrorMessage())
        }
        
        // 配置数据库
        sqlite3_exec(db, "PRAGMA synchronous = \(config.synchronousMode.description)", nil, nil, nil)
        sqlite3_exec(db, "PRAGMA journal_mode = \(config.journalMode.description)", nil, nil, nil)
        sqlite3_exec(db, "PRAGMA page_size = \(config.pageSize)", nil, nil, nil)
        sqlite3_exec(db, "PRAGMA cache_size = \(config.cacheSize)", nil, nil, nil)
        
        if !tableExist() {
            print("数据表 \(tableName) 不存在." )
            createTable()
        } else {
            print("数据表 \(tableName) 已存在." )
        }
    }
    
    @discardableResult public func createTable() ->Bool {
        
        let sql = NSString(string: "create table \(tableName) (a text, b text, c integer, d double, e double)")
        var pStmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, sql.utf8String, -1, &pStmt, nil) != SQLITE_OK {
            sqlite3_finalize(pStmt)
            print("编译 SQL 语句失败：", lastErrorMessage())
            return false
        }
        
        let result = sqlite3_step(pStmt)
        if result == SQLITE_OK || result == SQLITE_DONE {
            print("数据表 \(tableName) 创建成功." )
        } else {
            print("数据表 \(tableName) 创建失败：", lastErrorMessage())
        }
        
        sqlite3_finalize(pStmt)
        return true
    }
    
    @discardableResult public func insert(row: Int, reuse: Bool = true) ->Bool {
        
        var result = true
        
        let sql = NSString(string: "insert into \(tableName) (a, b, c, d, e) values (?, ?, ?, ?, ?)")
        
        var pStmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, sql.utf8String, -1, &pStmt, nil) != SQLITE_OK {
            sqlite3_finalize(pStmt)
            print("编译 SQL 语句失败：", lastErrorMessage())
            return false
        }
        
        for index in 0..<row {
//            print("row = ", index)
            autoreleasepool {
                sqlite3_bind_text(pStmt, 1, NSString(string: "abc\(index)").utf8String, -1, SQLITE_STATIC)
                sqlite3_bind_text(pStmt, 2, NSString(string: "dde\(index)").utf8String, -1, SQLITE_STATIC)
            }
            sqlite3_bind_int64(pStmt, 3, 30)
            sqlite3_bind_double(pStmt, 4, 40.0)
            sqlite3_bind_double(pStmt, 5, 50.0)
            if SQLITE_DONE != sqlite3_step(pStmt) {
                print("插入数据失败：", lastErrorMessage())
                result = false
                break
            }
            if reuse {
                sqlite3_reset(pStmt)
            } else {
                sqlite3_finalize(pStmt)
                if sqlite3_prepare_v2(db, sql.utf8String, -1, &pStmt, nil) != SQLITE_OK {
                    sqlite3_finalize(pStmt)
                    print("编译 SQL 语句失败：", lastErrorMessage())
                    return false
                }
            }
        }
        
        if reuse {
            print("复用模式下插入数据完成.")
        } else {
            print("非复用模式下插入数据完成.")
        }

        sqlite3_finalize(pStmt)
        return result
    }
    
    @discardableResult public func query(limit: Int, offset: Int) ->Bool {
        
        let sql = NSString(string: "select * from \(tableName) order by _rowid_ limit \(limit) offset \(offset)")
        
        var pStmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, sql.utf8String, -1, &pStmt, nil) != SQLITE_OK {
            sqlite3_finalize(pStmt)
            print("编译 SQL 语句失败：", lastErrorMessage())
            return false
        }
        
        while SQLITE_ROW == sqlite3_step(pStmt) {
            let val = sqlite3_column_text(pStmt, 1)
            let str = String(cString: val!)
//            print("str = ", str)
        }
        
        sqlite3_finalize(pStmt)
        return true
    }
    
    func rows() -> Int64 {

        var row = Int64(-1)
        
        let sql = NSString(string: "select count(*) from \(tableName)")
        
        var pStmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, sql.utf8String, -1, &pStmt, nil) != SQLITE_OK {
            sqlite3_finalize(pStmt)
            print("编译 SQL 语句失败：", lastErrorMessage())
            return row
        }
        
        if SQLITE_ROW == sqlite3_step(pStmt) {
            row = sqlite3_column_int64(pStmt, 0)
        }
        
        sqlite3_finalize(pStmt)
        
        return row
    }
    
    @discardableResult public func beginTransaction() -> Bool {
        return beginExclusiveTransaction()
    }
    
    @discardableResult public func beginDeferredTransaction() -> Bool {
        let sql = NSString(string: "begin deferred transaction")
        let result = sqlite3_exec(db, sql.utf8String, nil, nil, nil)
        return (result == SQLITE_DONE || result == SQLITE_OK)
    }
    
    @discardableResult public func beginExclusiveTransaction() -> Bool {
        let sql = NSString(string: "begin exclusive transaction")
        let result = sqlite3_exec(db, sql.utf8String, nil, nil, nil)
        return (result == SQLITE_DONE || result == SQLITE_OK)
    }
    
    @discardableResult public func rollback() -> Bool {
        let sql = NSString(string: "rollback transaction")
        let result = sqlite3_exec(db, sql.utf8String, nil, nil, nil)
        return (result == SQLITE_DONE || result == SQLITE_OK)
    }
    
    @discardableResult public func commit() -> Bool {
        let sql = NSString(string: "commit transaction")
        let result = sqlite3_exec(db, sql.utf8String, nil, nil, nil)
        return (result == SQLITE_DONE || result == SQLITE_OK)
    }
    
    public func tableExist() -> Bool {
        
        let sql = NSString(string: "select [sql] from sqlite_master where [type] = 'table' and lower(name) = ?")
        var pStmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, sql.utf8String, -1, &pStmt, nil) != SQLITE_OK {
            sqlite3_finalize(pStmt)
            print("编译 SQL 语句失败：", lastErrorMessage())
            return false
        }
        
        sqlite3_bind_text(pStmt, 1, tableName.cString(using: .utf8), -1, SQLITE_STATIC)
        
        let result = sqlite3_step(pStmt)
        
        sqlite3_finalize(pStmt)
        
        return (result == SQLITE_ROW)
    }
    
    public func lastErrorMessage() -> String {
        return String(cString: sqlite3_errmsg(db), encoding: .utf8) ?? ""
    }
}

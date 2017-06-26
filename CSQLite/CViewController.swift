//
//  CViewController.swift
//  CSQLite
//
//  Created by yanwei on 17/6/22.
//  Copyright © 2017年 clou. All rights reserved.
//

import UIKit

typealias Function = () -> Void

public func calculatCostTime(function: Function) -> Double {
    let startTime = CFAbsoluteTimeGetCurrent()
    function()
    let endTime = CFAbsoluteTimeGetCurrent()
    return endTime - startTime
}

public func repeatCalculateAvgCostTime(count: Int, function: Function) -> Double {
    var time = Double(0)
    for _ in 0..<count {
        time += calculatCostTime(function: function)
    }
    return time / Double(count)
}

// MARK: - 外部接口
extension CViewController {
    
}

// MARK: - 事件响应(数据库相关)
extension CViewController {
    
    /// 比较查寻在是否开启事务下的性能
    public func queryCompare() {
        // 初始化
        singleViewModel.setup()
        // 设置行数为500000
        singleViewModel.row = 500000
        // 开启事务,提高写入速度
        singleViewModel.isTransaction = true
        // 串行同步插入数据
        _ = singleViewModel.serialInsert()
        print("row = ", singleViewModel.rowsOfTable())
        
        // 重复 5 次获取开启事务读取 500000 条数据平均时间
        var transactionCost = Double(0)
        for _ in 0..<5 {
            transactionCost += singleViewModel.serialQuery()
        }
        transactionCost = transactionCost / 5
        
        // 关闭事务,提高写入速度
        singleViewModel.isTransaction = false
        
        // 重复 5 次获取不开启事务读取 500000 条数据平均时间
        var noTransactionCost = Double(0)
        for _ in 0..<5 {
            noTransactionCost += singleViewModel.serialQuery()
        }
        noTransactionCost = noTransactionCost / 5
        
        print("transactionCost = ", transactionCost)
        print("noTransactionCost = ", noTransactionCost)
    }
    
    /// 比较插入在是否开启事务下的性能
    public func insertCompare() {
        // 初始化
        singleViewModel.setup()
        // 设置行数为5000
        singleViewModel.row = 5000

        print("row = ",  singleViewModel.rowsOfTable())
        
        // 重复 5 次获取在隐式事务写入 5000 条数据平均时间
        var noTransactionCost = Double(0)
        for _ in 0..<50 {
            noTransactionCost += singleViewModel.serialInsert()
        }
        noTransactionCost = noTransactionCost / 50

        // 开启事务
        singleViewModel.isTransaction = true
        
        // 重复 5 次获取不开启事务读取 5000 条数据平均时间
        var transactionCost = Double(0)
        for _ in 0..<50 {
            transactionCost += singleViewModel.serialInsert()
        }
        transactionCost = transactionCost / 50
        
        print("transactionCost = ", transactionCost)
        print("noTransactionCost = ", noTransactionCost)
    }
    
    /// 比较重用 VDBE 语句下的性能
    public func reuseCompare() {
        // 初始化
        singleViewModel.setup()
        // 设置行数为 500000
        singleViewModel.row = 500000
        // 开启事务
        singleViewModel.isTransaction = true
        
        print("row = ", singleViewModel.rowsOfTable())
        
        // 设置不重用 VDEB 语句
        singleViewModel.reuse = true
        
        // 重复 5 次获取在不重用 VDEB 语句情况下写入 5000 条数据平均时间
        var noReuseCost = Double(0)
        for _ in 0..<5 {
            noReuseCost += singleViewModel.serialInsert()
        }
        noReuseCost = noReuseCost / 5
        
        // 设置重用 VDEB 语句
        singleViewModel.reuse = true
        
        // 重复 5 次获取在重用 VDEB 语句情况下写入 5000 条数据平均时间
        var reuseCost = Double(0)
        for _ in 0..<5 {
            reuseCost += singleViewModel.serialInsert()
        }
        reuseCost = reuseCost / 5
        
        print("transactionCost = ", reuseCost)
        print("noTransactionCost = ", noReuseCost)
    }
    
    public func initDatabase() {
        singleViewModel.setup()
        print("rows = ", singleViewModel.rowsOfTable())
        singleViewModel.run()
        print("rows = ", singleViewModel.rowsOfTable())
    }
    
    public func insertData() {
        mulTableViewModel.setup()
        print("rows = ", mulTableViewModel.rowsOfTable())
        mulTableViewModel.run()
        print("rows = ", mulTableViewModel.rowsOfTable())
    }
    
    public func queryData() {
        mulDbViewModel.setup()
        print("rows = ", mulDbViewModel.rowsOfTable())
        mulDbViewModel.run()
        print("rows = ", mulDbViewModel.rowsOfTable())
    }
    
    public func mulTableQueryData() {

    }
    
    public func mulDbQueryData() {

    }
}

// MARK: - 事件响应(UI相关)
extension CViewController {
    
    public func reuseOperation() {
        if singleViewModel.reuse {
            reuseButton.setTitle("开启复用", for: .normal)
        } else {
            reuseButton.setTitle("关闭复用", for: .normal)
        }
        singleViewModel.reuse = !singleViewModel.reuse
    }
}

public class CViewController: UIViewController {
    
    // MARK: - 生命周期
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupParameter()
        setupUI()
        layoutPageSubviews()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - 界面初始化
    
    
    /// 初始化UI
    fileprivate func setupUI() {
        view.backgroundColor = UIColor(red:0.00, green:0.59, blue:0.53, alpha:1.00)
        
        initButton.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
        initButton.center = view.center
        view.addSubview(initButton)
        
        insertButton.bounds = initButton.bounds
        insertButton.center = CGPoint(x: initButton.center.x, y: initButton.frame.maxY + 40)
        view.addSubview(insertButton)
        
        queryButton.bounds = initButton.bounds
        queryButton.center = CGPoint(x: initButton.frame.maxX + 40, y: initButton.center.y)
        view.addSubview(queryButton)
        
        mulInsertButton.bounds = initButton.bounds
        mulInsertButton.center = CGPoint(x: initButton.frame.minX - 40, y: initButton.center.y)
        view.addSubview(mulInsertButton)
        
        reuseButton.bounds = CGRect(x: 0, y: 0, width: 90, height: 45)
        reuseButton.center = CGPoint(x: insertButton.center.x, y: insertButton.frame.maxY + 100)
        view.addSubview(reuseButton)
    }
    
    /// 初始化布局
    fileprivate func layoutPageSubviews() {
        
    }
    
    /// 初始化参数
    fileprivate func setupParameter() {
        
    }
    
    
    // MARK: - 内部接口
    
    
    // MARK: - 公共成员变量
    
    
    // MARK: - 私有成员变量
    
    fileprivate var singleViewModel = CSingleDbViewModel()
    
    fileprivate var mulTableViewModel = CMulTableViewModel()
    
    fileprivate var mulDbViewModel = CMulDbViewModel()
    
    // MARK: - 子控件
    
    
    /// 数据库初始化按钮
    fileprivate lazy var initButton: UIButton = {
        let button = UIButton()
        button.setTitle("读事务比较", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)
        button.backgroundColor = UIColor(red:0.01, green:0.66, blue:0.95, alpha:1.00)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(self.queryCompare), for: .touchUpInside)
        return button
    }()
    
    /// 插入数据按钮
    fileprivate lazy var insertButton: UIButton = {
        let button = UIButton()
        button.setTitle("写事务比较", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)
        button.backgroundColor = UIColor(red:0.01, green:0.66, blue:0.95, alpha:1.00)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(self.insertCompare), for: .touchUpInside)
        return button
    }()
    
    /// 复用按钮
    fileprivate lazy var reuseButton: UIButton = {
        let button = UIButton()
        button.setTitle("重用语句", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)
        button.backgroundColor = UIColor(red:0.01, green:0.66, blue:0.95, alpha:1.00)
        button.addTarget(self, action: #selector(self.reuseCompare), for: .touchUpInside)
        return button
    }()
    
    /// 查寻按钮
    fileprivate lazy var queryButton: UIButton = {
        let button = UIButton()
        button.setTitle("多库单表", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)
        button.backgroundColor = UIColor(red:0.01, green:0.66, blue:0.95, alpha:1.00)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(self.queryData), for: .touchUpInside)
        return button
    }()
    
    /// 多次插入按钮
    fileprivate lazy var mulInsertButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)
        button.backgroundColor = UIColor(red:0.01, green:0.66, blue:0.95, alpha:1.00)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(self.mulDbQueryData), for: .touchUpInside)
        return button
    }()
}

//
//  BaseTableViewCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/16.
//

import UIKit

protocol BaseTableViewCellProtol {
    // ⭐️ 修改为 static var，表示这是一个类属性/类型属性
    static var baseIdentifier: String { get }
}

class BaseTableViewCell: UITableViewCell, BaseTableViewCellProtol {
    // ⭐️ 自动实现 baseIdentifier，返回类名
    static var baseIdentifier: String {
        return String(describing: Self.self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        // 强制要求使用代码初始化 Cell
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 抽象方法
    
    func setupViews() {
    }
    
    // MARK: - 性能优化
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

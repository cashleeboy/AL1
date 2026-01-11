//
//  BaseFormCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit

class BaseFormCell: FormCell {
    
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
}

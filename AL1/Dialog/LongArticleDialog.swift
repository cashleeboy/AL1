//
//  LongArticleDialog.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit
import SnapKit

class LongArticleDialog: BaseDialog {

    private var articles: [NSMutableAttributedString] = []
    var onRejectHandler: (() -> Void)?
    var onPrimaryHandler: (() -> Void)?
    
    // MARK: - UI Components
    
    lazy var tableView: UITableView = {
        let tabView = UITableView()
        tabView.delegate = self
        tabView.dataSource = self
        tabView.separatorStyle = .none
        tabView.backgroundColor = .clear
        tabView.showsVerticalScrollIndicator = true
        // 注册一个简单的 Cell
        tabView.register(UITableViewCell.self, forCellReuseIdentifier: "ArticleCell")
        return tabView
    }()

    lazy var rejectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = AppFontProvider.shared.getFont12Regular()
        
        let color = UIColor(hex: "#A4A4A4")
        button.setAttributedTitle(NSMutableAttributedString(string: "Rechazo", color: color), for: .normal)
        button.addTarget(self, action: #selector(rejectAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Setup
    
    override func setupViews() {
        super.setupViews()
        // 1. 初始化父类组件状态
        primaryButton.setTitle("Acepto", for: .normal)
        
        // 2. 添加到 contentView (注意：BaseDialog 里的子组件通常在 contentView 中)
        contentView.addSubview(tableView)
        contentView.addSubview(rejectButton)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(35)
        }
        
        // 3. 重新布局
        // 标题已在 BaseDialog 中布局，此处处理其他组件
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            // 固定高度或者根据屏幕比例调整，防止弹窗过长
            make.height.equalTo(250)
        }

        primaryButton.snp.remakeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(50)
        }

        rejectButton.snp.makeConstraints { make in
            make.top.equalTo(primaryButton.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20) // 闭合约束链
        }
        
        let width = UIScreen.main.bounds.width - 60
        contentView.snp.remakeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(width)
        }
    }

    // MARK: - Actions
    
    @objc func rejectAction() {
        onRejectHandler?()
    }
    
    override func handlePrimaryAction() {
        onPrimaryHandler?()
    }

    func configure(with title: String, articles: [NSMutableAttributedString], primaryAction:(() -> Void)?, rejectAction: (() -> Void)?) {
        titleLabel.text = title
        self.articles = articles
        self.onRejectHandler = rejectAction
        self.onPrimaryHandler = primaryAction
        tableView.reloadData()
        
        // 重新计算并更新弹窗大小
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension LongArticleDialog: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        // 设置文本样式
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = AppFontProvider.shared.getFont13Regular()
        cell.textLabel?.textColor = UIColor(hex: "#202020")
        cell.textLabel?.attributedText = articles[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}

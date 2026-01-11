//
//  ServiceDialog.swift
//  AL1
//
//  Created by cashlee on 2025/12/15.
//

import UIKit
import SnapKit

class ServiceContactDialog: BaseDialog {
    // MARK: - 属性
    private var items: [ServiceInquiryItem] = []
    var onDismiss: () -> Void
    var callServiceAction: ((ServiceInquiryItem) -> Void)?
    
    private let topBgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "login_service_head_bg")
        imageView.clipsToBounds = false
        return imageView
    }()
    
    private let rightIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "login_service_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        return imageView
    }()
    
    private lazy var tableView: UITableView = {
        let tableV = UITableView(frame: .zero, style: .plain)
        tableV.delegate = self
        tableV.dataSource = self
        tableV.separatorStyle = .none
        tableV.backgroundColor = .clear
        tableV.showsVerticalScrollIndicator = false
        tableV.register(ServiceItemCell.self, forCellReuseIdentifier: "ServiceContactDialog")
        return tableV
    }()
    
    private lazy var serviceTimeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 30
        view.backgroundColor = AppColorStyle.shared.brandPrimary
        return view
    }()
    
    private lazy var serviceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Servicio al cliente en línea"
        label.textColor = AppColorStyle.shared.backgroundWhite
        label.font = AppFontProvider.shared.getFont16Bold()
        return label
    }()
    
    private lazy var serviceTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Horario de trabajo: 8:30-18:00"
        label.textColor = AppColorStyle.shared.backgroundWhite
        label.font = AppFontProvider.shared.getFont11Regular()
        return label
    }()
    
    // MARK: - 初始化
    
    init(dismiss: @escaping (() -> Void)) {
        self.onDismiss = dismiss
        super.init()
        
        contentView.clipsToBounds = false
        titleLabel.textColor = AppColorStyle.shared.backgroundWhite
        titleLabel.font = AppFontProvider.shared.getFont16Bold()
        cancelButton.addTarget(self, action: #selector(cancelTap), for: .touchUpInside)
        primaryButton.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局设置
    override func setupViews() {
        super.setupViews()
        
        // 移除不使用的组件
        primaryButton.removeFromSuperview()
        messageLabel.removeFromSuperview()
        
        // topBgImageView 应该位于 contentView 内部
        contentView.addSubview(topBgImageView)
        topBgImageView.addSubview(rightIconImageView)
        topBgImageView.addSubview(titleLabel)
        
        contentView.addSubview(tableView)
        contentView.addSubview(serviceTimeView)
        serviceTimeView.addSubview(serviceTitleLabel)
        serviceTimeView.addSubview(serviceTimeLabel)
        addSubview(cancelButton)
        
        // --- 2. 约束常量 ---
        let headerHeight: CGFloat = 60 // 顶部橙色背景的高度
        let contentMargin: CGFloat = 20
        let serviceButtonHeight: CGFloat = 60 // 底部服务按钮的高度
        
        // --- 3. 头部背景约束 (topBgImageView) ---
        topBgImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
        
        // 3.1 头部标题 (Service al Cliente)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(contentMargin)
            make.centerY.equalToSuperview()
        }
        
        rightIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-contentMargin)
            make.bottom.equalTo(titleLabel.snp.centerY).offset(10)
            make.size.equalTo(60) // 假设图标尺寸
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(topBgImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(serviceTimeView.snp.top).offset(-20)
            
            // 关键点：这里不再写死高度范围，而是给一个初始理想高度
            // 我们改用 remakeConstraints 来动态调整
            make.height.equalTo(150)
        }
        
        // --- 5. 底部服务时间按钮约束 (serviceTimeView) ---
        serviceTimeView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().offset(30)
            make.trailing.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(serviceButtonHeight) // 固定高度
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 5.1 服务标题和时间标签 (居中)
        serviceTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        serviceTimeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(serviceTitleLabel.snp.bottom).offset(5)
        }
        
        // 将高度限制加在 contentView 上，保护弹窗整体不会过大或过小
        let screenHeight = UIScreen.main.bounds.height
        contentView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(340)
            make.height.greaterThanOrEqualTo(300) // 弹窗总高度最小值
            make.height.lessThanOrEqualTo(screenHeight * 0.8) // 弹窗总高度最大值
        }
        
        cancelButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.centerX.equalToSuperview()
            make.top.equalTo(contentView.snp.bottom).offset(40)
        }   
    }
    
    // MARK: - 配置方法
    func configure(title: String, items: [ServiceInquiryItem]) {
        titleLabel.text = title
        self.items = items
        self.tableView.reloadData()
        
        // 刷新布局以适应内容高度
        self.tableView.layoutIfNeeded()
        let contentH = self.tableView.contentSize.height
        
        // 使用 remakeConstraints 避免与之前的约束冲突
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(topBgImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(serviceTimeView.snp.top).offset(-20)
            
            // 动态计算：在 150 到 250 之间取值
            let finalHeight = max(170, min(contentH, 270)) + 50
            make.height.equalTo(finalHeight)
        }
        
        // 通知容器重新布局
        self.layoutIfNeeded()
    }
    
    @objc func cancelTap() {
        onDismiss()
    }
}

extension ServiceContactDialog: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceContactDialog", for: indexPath) as! ServiceItemCell
        let item = items[indexPath.row]
        cell.configure(with: item)
        cell.onActionTap = { [weak self] in
            self?.callServiceAction?(item)
        }
        return cell
    }
}

class ServiceItemCell: UITableViewCell {
    var onActionTap: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColorStyle.shared.textGray8E
        label.font = AppFontProvider.shared.getFont12Medium()
        return label
    }()
    
    private let itemView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = AppColorStyle.shared.textGrayF6
        return view
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColorStyle.shared.texBlack33
        label.font = AppFontProvider.shared.getFont16Bold()
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(AppColorStyle.shared.brandPrimary, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont10Medium()
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(itemView)
        itemView.addSubview(valueLabel)
        itemView.addSubview(actionButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview()
        }
        
        itemView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
        
        actionButton.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
    }
    
    func configure(with item: ServiceInquiryItem) {
        let type = item.inquiryTypes.first
        titleLabel.text = type?.displayName
        valueLabel.text = item.content
        actionButton.setTitle(type?.functionTitle, for: .normal)
    }
    
    @objc private func btnClick() { onActionTap?() }
}

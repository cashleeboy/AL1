//
//  NetworkErrorDialog.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//
 
import UIKit
import SnapKit

class NetworkErrorDialog: BaseDialog {
    
    // MARK: - 独有组件
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dialog_error_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // 动作按钮（三个，使用数组或单独定义，这里使用单独定义）
    private let wifiButton = NetworkActionButton()
    private let updateButton = NetworkActionButton()
    private let mobileDataButton = NetworkActionButton()
    
    // 动作闭包
    var wifiAction: DialogAction?
    var updateAction: DialogAction?
    var mobileDataAction: DialogAction?

    // MARK: - 初始化
    
    override init() {
        super.init()
        
        // 绑定动作
        cancelButton.tintColor = AppColorStyle.shared.textGray // 灰色 X 图标
        cancelButton.addTarget(self, action: #selector(cancelTap), for: .touchUpInside)
        wifiButton.addTarget(self, action: #selector(wifiActionTapped), for: .touchUpInside)
        updateButton.addTarget(self, action: #selector(updateActionTapped), for: .touchUpInside)
        mobileDataButton.addTarget(self, action: #selector(mobileDataActionTapped), for: .touchUpInside)
        
        // 由于这个 Dialog 有非常规的按钮，我们需要隐藏 BaseDialog 的主按钮
        primaryButton.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 动作处理
    
    @objc func cancelTap() {
        
    }
    
    @objc func wifiActionTapped() {
        wifiAction?()
        
    }
    
    @objc func updateActionTapped() {
        updateAction?()
        
    }
    
    @objc func mobileDataActionTapped() {
        mobileDataAction?()
        
    }

    // MARK: - 布局设置
    override func setupViews() {
        // 确保 titleLabel, messageLabel, primaryButton 已被添加到 contentView (来自 BaseDialog)
        super.setupViews()
        
        // 移除不使用的 primaryButton
        primaryButton.removeFromSuperview()
        
        // 重新添加和布局组件
        contentView.addSubview(cancelButton)
        contentView.addSubview(iconImageView)
        // titleLabel 和 messageLabel 已经在 super.setupViews() 中添加
        contentView.addSubview(wifiButton)
        contentView.addSubview(updateButton)
        contentView.addSubview(mobileDataButton)
        
        let margin: CGFloat = 20
        let buttonHeight: CGFloat = 50
        
        // 1. 取消按钮 (右上角)
        cancelButton.snp.makeConstraints { make in
            make.size.equalTo(24) // 减小尺寸
            make.trailing.equalToSuperview().offset(-margin)
            make.top.equalToSuperview().offset(margin)
        }
        
        // 2. 图标 (居中)
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(margin + 10)
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        
        // 3. 标题 (居中，在图标下方)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(margin)
        }
        
        // 4. 消息 (居中，在标题下方)
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(margin)
            // 确保消息底部与第一个按钮有间隔
        }
        
        // 5. 动作按钮区域 (垂直堆叠)
        
        // 5.1 WiFi 按钮 (第一个按钮)
        wifiButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(buttonHeight)
        }
        
        // 5.2 更新按钮
        updateButton.snp.makeConstraints { make in
            make.top.equalTo(wifiButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(buttonHeight)
        }
        
        // 5.3 移动数据按钮 (最后一个按钮，撑开底部)
        mobileDataButton.snp.makeConstraints { make in
            make.top.equalTo(updateButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(buttonHeight)
            make.bottom.equalToSuperview() // 撑开 contentView 底部，无额外 margin
        }
        
        // 约束 contentView 宽度 (固定宽度)
        contentView.snp.remakeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(300)
        }
    }
    
    // MARK: - 配置方法
    
    func configure(
        title: String,
        message: String,
        wifiAction: DialogAction? = nil,
        updateAction: DialogAction? = nil,
        mobileDataAction: DialogAction? = nil
    ) {
        titleLabel.text = title // "Error de red"
        messageLabel.text = message // "Compruebe si está conectado..."
        
        // 确保 titleLabel 居中对齐
        titleLabel.textAlignment = .center
        messageLabel.textAlignment = .center
        
        // 配置按钮文本
        wifiButton.setTitle("Wi-Fi", for: .normal)
        updateButton.setTitle("Actualizar", for: .normal)
        mobileDataButton.setTitle("Datos móviles", for: .normal)
        
        // 绑定动作
        self.wifiAction = wifiAction
        self.updateAction = updateAction
        self.mobileDataAction = mobileDataAction
    }
}

// MARK: - 辅助结构：用于底部纯文本按钮

private class NetworkActionButton: UIButton {
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColorStyle.shared.backgroundLightGray // 假设浅灰色
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.titleLabel?.font = AppFontProvider.shared.getFont16Bold()
        self.setTitleColor(AppColorStyle.shared.texBlack33, for: .normal) // 假设文本是蓝色
        self.backgroundColor = .clear
        
        // 添加分隔线
        self.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1) // 细线
        }
    }
}

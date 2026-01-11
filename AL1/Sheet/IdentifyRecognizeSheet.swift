//
//  IdentifyRecognizeSheet.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

class IdentifyRecognizeSheet: BaseSheet {
    
    lazy var correctExampleImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "identify_recognize_icon") // 对应图中 Example 区域
        return iv
    }()
    
    lazy var primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.backgroundColor = AppColorStyle.shared.brandPrimary
        button.setTitleColor(AppColorStyle.shared.backgroundWhite, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont18Semibold()
        button.setTitle("Volver a tomar", for: .normal)
        return button
    }()
    
    var primaryHandler: (() -> Void)?
    
    override func setupViews() {
        titleLabel.removeFromSuperview()
        
        contentView.addSubview(correctExampleImageView)
        contentView.addSubview(primaryButton)
        
        primaryButton.addTarget(self, action: #selector(primaryAction), for: .touchUpInside)
        
        setupLayout()
    }
    
        
    private func setupLayout() {
        // 中央示例图约束 (包含图中正确/错误对比的所有内容建议切成一张大图或者使用图片容器)
        correctExampleImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.right.equalToSuperview().inset(20)
            // 根据 UI 图比例计算高度，通常身份证比例约为 1.6
            make.height.equalTo(correctExampleImageView.snp.width).multipliedBy(0.8)
        }
        
        // 底部按钮约束
        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(correctExampleImageView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
            // 关键：底部留白并闭合 contentView 约束链以供 BaseSheet 计算高度
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    @objc func primaryAction() {
        handleCancelAction()
        primaryHandler?()
    }
}

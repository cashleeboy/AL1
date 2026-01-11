//
//  TopBannerContainer.swift
//  AL1
//
//  Created by cashlee on 2025/12/16.
//

import UIKit
import SnapKit

class TopBannerContainer: UIView
{
    let message: String
 
    private lazy var warnImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "warning_banner_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont11Regular()
        label.textColor = AppColorStyle.shared.textBlack33
        label.numberOfLines = 0
        label.text = "¡Atención! No transfiera fondos a ninguna cuenta personal."
        return label
    }()
    
    // ⭐️ 核心：使用横向堆栈视图
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [warnImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center // 垂直居中对齐
        stackView.spacing = 10        // 图标和文字的间距
        stackView.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        return stackView
    }()
    
    // MARK: - 初始化
    
    init(frame: CGRect, message: String = "¡Atención! No transfiera fondos a ninguna cuenta personal.") {
        self.message = message
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局设置
    
    private func setupViews() {
        backgroundColor = AppColorStyle.shared.lightBrandPrimary
        addSubview(contentStackView)
        
        // 布局 StackView
        contentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            // 建议：稍微减小上下 padding 或者使用 priority 允许压缩
            make.top.equalToSuperview().offset(20).priority(.high)
            make.bottom.equalToSuperview().offset(-8).priority(.high)
        }
        
        warnImageView.snp.makeConstraints { make in
            make.size.equalTo(16)
            // ⭐️ 核心解决：降低高度优先级，防止与外部强制高度冲突
            make.height.equalTo(16).priority(.medium)
        }
        
        titleLabel.text = message
    }
    
    // MARK: - 逻辑处理
    func updateBannerStatus(text: String, showWarning: Bool = true, textColor: UIColor) {
        titleLabel.text = text
        titleLabel.textColor = textColor
        
        warnImageView.isHidden = !showWarning
        
        if text.isEmpty {
            self.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        } else {
            // 移除高度限制或恢复
        }
        
        // 执行布局动画
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
}

//
//  ConfirmLoanHeaderCell.swift
//  AL1
//
//  Created by cashlee on 2026/1/26.
//

import UIKit
import SnapKit

struct ConfirmLoanHeaderModel: IdentifiableTableItem { 
    let identifier: String = "PrestamoHeaderSelectionCell"
    let statusTitle: String = "Aplicación exitosa" // 新增
    let title: String = "Las personas que solicitaron este producto también solicitaron"
}

extension ConfirmLoanHeaderModel: PrestamoRowConvertible {
    func toRow(action: ((ConfirmLoanHeaderModel) -> Void)?) -> RowRepresentable {
        return ConcreteRow<ConfirmLoanHeaderModel, ConfirmLoanHeaderCell>(item: self, didSelectAction: action)
    }
}

class ConfirmLoanHeaderCell: BaseConfigurablewCell {
    // 1. 背景容器（圆角卡片）
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white // 根据图片取色
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()

    // 2. 状态图标
    private lazy var statusIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "empty_funding_right"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // 3. 成功状态文本
    private lazy var successLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = AppFontProvider.shared.getFont18Semibold() // 建议加粗
        label.textAlignment = .center
        return label
    }()

    // 4. 底部提示文本（原本已有的 titleLabel）
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0 // 支持换行
        label.font = AppFontProvider.shared.getFont14Regular()
        return label
    }()
    
    // MARK: - 布局设置
    override func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(statusIcon)
        containerView.addSubview(successLabel)
        contentView.addSubview(titleLabel)

        // 背景卡片约束
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(200) // 根据设计稿调整
        }

        // 图标约束
        statusIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize(width: 100, height: 100))
        }

        // 成功文案约束
        successLabel.snp.makeConstraints { make in
            make.top.equalTo(statusIcon.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        // 底部提示文本约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-15) // 底部间距
        }
    }
    
    override func configure(with item: any TableItemProtocol) {
        guard let loanItem = item as? ConfirmLoanHeaderModel else { return }
        titleLabel.text = loanItem.title
        successLabel.text = loanItem.statusTitle
    }
}

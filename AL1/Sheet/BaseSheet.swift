//
//  BaseSheet.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit
import SnapKit

class BaseSheet: UIView {
    let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont16Bold()
        label.textColor = AppColorStyle.shared.texBlackDialog
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "dialog_cancel_icon"), for: .normal)
        return button
    }()
    
    var titleLabelTopConstraint: Constraint?
    var dismissHandler: (() -> Void)
    
    init(_ frame: CGRect = .zero, dismissHandler: @escaping () -> Void) {
        self.dismissHandler = dismissHandler
        super.init(frame: frame)
        setupBaseUI()
        setupViews()
        cancelButton.addTarget(self, action: #selector(handleCancelAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupBaseUI() {
        self.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(cancelButton)
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            titleLabelTopConstraint = make.top.equalToSuperview().offset(20).constraint
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(30)
        }
    }
    
    func setupViews() {}
    
    func configure(title: String?, topSpace: CGFloat?) {
        if let title {
            titleLabel.text = title
        }
        if let topSpace {
            titleLabel.snp.updateConstraints { make in
                titleLabelTopConstraint = make.top.equalToSuperview().offset(topSpace).constraint
            }
        }
    }
    
    @objc func handleCancelAction() {
        dismissHandler()
    }
}

extension BaseSheet {
    func calculateFittingSize(for targetWidth: CGFloat = UIScreen.main.bounds.width) -> CGSize {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        let targetSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        let fittingSize = self.contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return fittingSize
    }
}


//
//  FeedbackSelectionCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/27.
//

import UIKit

struct FeedbackSelectionModel: IdentifiableTableItem {
    static let userIdeitifiter = "AcercaMeSelectionCell"
    let identifier: String = FeedbackSelectionModel.userIdeitifiter
    let placeholder: String = "Describa su problema en detalle y le brindaremos una mejor ayuda."
    var onTextviewDidChange: ((String) -> Void)
    init(onTextviewDidChange: @escaping (String) -> Void) {
        self.onTextviewDidChange = onTextviewDidChange
    }
}

extension FeedbackSelectionModel: PrestamoRowConvertible {
    func toRow(action: ((FeedbackSelectionModel) -> Void)?) -> RowRepresentable {
        return ConcreteRow<FeedbackSelectionModel, FeedbackSelectionCell>(item: self, didSelectAction: action)
    }
}

class FeedbackSelectionCell: BaseConfigurablewCell {
    private var model: FeedbackSelectionModel?
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        view.layer.cornerRadius = 15
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textV = UITextView()
        textV.font = AppFontProvider.shared.getFont14Regular()
        textV.textColor = AppColorStyle.shared.textBlack33
        textV.backgroundColor = .clear
        // 设置输入内容的内边距
        textV.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        textV.delegate = self
        // 隐藏滚动条让视觉更整洁
        textV.showsVerticalScrollIndicator = false
        return textV
    }()
    // 自定义占位符 Label
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Regular()
        label.textColor = UIColor(hex: "#A0A0A0") // 浅灰色占位符
        label.numberOfLines = 0
        return label
    }()
    
    override func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(placeholderLabel)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.greaterThanOrEqualTo(200) // 设置最小高度
        }
        
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 占位符约束：对齐 textView 的文字起始位置
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
    }
    
    override func configure(with item: any TableItemProtocol) {
        guard let model = item as? FeedbackSelectionModel else { return }
        self.model = model
        placeholderLabel.text = model.placeholder
        // 初始状态判断占位符显示
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension FeedbackSelectionCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 1. 控制占位符显示
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        // 2. 回调文字更改到 Model
        model?.onTextviewDidChange(textView.text)
        
        // 3. (可选) 如果需要 Cell 高度随文字自动增高，需触发 TableView 更新
        // let size = textView.bounds.size
        // let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        // if size.height != newSize.height {
        //     // 发送通知让外部 reloadData 或 updateConstraints
        // }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 获得焦点时可以改变容器边框颜色 (可选视觉细节)
        containerView.layer.borderColor = UIColor.orange.cgColor
        containerView.layer.borderWidth = 1.0
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        containerView.layer.borderWidth = 0
    }
}

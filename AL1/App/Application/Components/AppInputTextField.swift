//
//  AppInputTextField.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

/// 通用业务输入框组件
class AppInputTextField: UITextField {

    // MARK: - 配置属性
    
    /// 内容相对于边框的内边距（不含左右视图占用的空间）
    var contentInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    /// 左右视图与文字之间的间距
    var viewSpacing: CGFloat = 8
    
    /// 默认边框颜色
    var normalBorderColor: UIColor = .clear {
        didSet { if !isEditing { layer.borderColor = normalBorderColor.cgColor } }
    }
    
    /// 激活状态边框颜色
    var activeBorderColor: UIColor = .clear {
        didSet { if isEditing { layer.borderColor = activeBorderColor.cgColor } }
    }

    // MARK: - 回调闭包 (Callbacks)
    
    var shouldBeginEditing: (() -> Bool)?
    var didBeginEditing: ((String?) -> Void)?
    var didEndEditing: ((String?) -> Void)?
    var textChanged: ((String?) -> Void)?
    var shouldReturn: ((String?) -> Void)?
    var shouldChangeCharacters: ((_ currentText: String?, _ replacement: String) -> Bool)?

    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBaseStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBaseStyle()
    }
    
    private func setupBaseStyle() {
        self.delegate = self
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 8
        self.layer.borderColor = normalBorderColor.cgColor
        
        self.leftViewMode = .always
        self.rightViewMode = .always
        self.clearButtonMode = .whileEditing
        self.returnKeyType = .search
        
        // 监听文字变化
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    // MARK: - 布局覆盖 (Layout Overrides)

    // 控制左视图的位置
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += contentInsets.left
        return rect
    }

    // 控制右视图的位置
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= contentInsets.right
        return rect
    }

    // 文字显示的区域
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return calculateRect(forBounds: bounds)
    }

    // 编辑状态下的文字区域
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return calculateRect(forBounds: bounds)
    }

    private func calculateRect(forBounds bounds: CGRect) -> CGRect {
        var inset = contentInsets
        
        // 如果有左视图，文字左侧需要增加：左视图宽度 + 间距
        if let left = leftView {
            inset.left += left.frame.width + viewSpacing
        }
        
        // 如果有右视图，文字右侧需要增加：右视图宽度 + 间距
        if let right = rightView {
            inset.right += right.frame.width + viewSpacing
        }
        
        return bounds.inset(by: inset)
    }
    
    // MARK: - 第一响应者控制
    
    override var canBecomeFirstResponder: Bool {
        return shouldBeginEditing?() ?? true
    }

    @objc private func textFieldDidChange() {
        textChanged?(self.text)
    }
}

// MARK: - UITextFieldDelegate 实现
extension AppInputTextField: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return shouldBeginEditing?() ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        layer.borderColor = activeBorderColor.cgColor
        didBeginEditing?(textField.text)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        layer.borderColor = normalBorderColor.cgColor
        didEndEditing?(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        shouldReturn?(textField.text)
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let nsString = currentText as NSString
        let newText = nsString.replacingCharacters(in: range, with: string)
        
        return shouldChangeCharacters?(newText, string) ?? true
    }
}

// MARK: - 快速创建辅助视图
extension AppInputTextField {
    
    /// 快速设置左侧图标
    func setLeftIcon(_ image: UIImage?, size: CGSize = CGSize(width: 20, height: 20)) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(origin: .zero, size: size)
        self.leftView = imageView
    }
    
    func setRightIcon(_ image: UIImage?, size: CGSize = CGSize(width: 20, height: 20)) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(origin: .zero, size: size)
        self.rightView = imageView
    }
}

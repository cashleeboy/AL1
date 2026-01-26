//
//  PhoneInputView.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//

import UIKit
 
typealias TextFieldChangeAction = (String?) -> Void

// 定义输入框的样式
enum PhoneInputStyle {
    // 样式 A: 手机号输入框 (左侧带国家码，无右侧视图)
    case phoneNumberInput(countryCode: String, placeholder: String, buttonTitle: String, buttonAction: DialogAction?)
    // 样式 B: OTP 输入框 (左侧无，右侧带“发送 OTP”按钮)
    case otpInput(placeholder: String, buttonTitle: String, buttonAction: DialogAction?)
    // 样式 C: 带有倒计时提示 (左侧无，右侧带倒计时文本)
    case otpCountdown(placeholder: String, countdownSeconds: String)
}

class PhoneInputView: UIView
{
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = AppColorStyle.shared.textGray94
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Medium()
        label.textColor = AppColorStyle.shared.semanticError
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    lazy var textFLeftView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var textFRightView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let countryCodeLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont16Regular()
        label.textColor = AppColorStyle.shared.textBlack
        label.textAlignment = .center
        return label
    }()
    
    private lazy var textField: CustomTextField = {
        let textF = CustomTextField(frame: .zero)
        textF.backgroundColor = AppColorStyle.shared.backgroundPagePrimary // 浅灰色底
        textF.layer.cornerRadius = 8
        textF.layer.masksToBounds = true
        textF.keyboardType = .numberPad
        textF.delegate = self
        textF.textColor = AppColorStyle.shared.textBlack33
        textF.font = AppFontProvider.shared.getFont16Medium()
        textF.setCustomPlaceholder(
            text: "Por favor escriba OTP",
            color: AppColorStyle.shared.textGrayA3,
            font: AppFontProvider.shared.getFont12Regular())
        return textF
    }()
    
    var text: String? {
        textField.text
    }
    
    var maxCount: Int {
        textField.maxCount
    }
    
    private var actionButton: UIButton?
    private var countdownLabel: UILabel?
    private var buttonAction: DialogAction?
    var textFieldAction: ((String, Bool) -> Void)?
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    func setMaxCount(_ count: Int) {
        textField.maxCount = count
    }
    
    func isBecomeFirstResponder() {
        textField.becomeFirstResponder()
    }
    
    
    private func setupUI() {
//        self.addSubview(mainStackView)
        mainStackView.addArrangedSubview(tipLabel)
        mainStackView.addArrangedSubview(textField)
//        mainStackView.addArrangedSubview(errorLabel)
        
        self.addSubview(tipLabel)
        self.addSubview(textField)
        self.addSubview(errorLabel)
        
//        mainStackView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//            make.leading.trailing.equalToSuperview()
//            make.top.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-10)
//            make.bottom.equalTo(errorLabel.snp.top).offset(-5)
//        }
        
        tipLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleAction() {
        buttonAction?()
    }
    
    // MARK: - 配置方法
    func configure(style: PhoneInputStyle)
    {
        textField.leftView = nil
        textField.rightView = nil
        textField.leftViewMode = .never
        textField.rightViewMode = .never
        textField.keyboardType = .numberPad
        
        // 2. 根据样式配置
        switch style {
        case .phoneNumberInput(let code, let placeholder, let buttonTitle, let action):
            textField.leftView = createLeftView(text: code)
            
            textField.leftViewMode = .always
            textField.placeholder = placeholder
            
            textField.rightView = createRightView(title: buttonTitle, action: action)
            textField.rightViewMode = .always
            textField.placeholder = placeholder
            
            // 确保边框颜色正常
            textField.layer.borderColor = nil
            textField.layer.borderWidth = 0
            
        case .otpInput(let placeholder, let buttonTitle, let action):
            textField.rightView = createRightView(title: buttonTitle, action: action)
            textField.rightViewMode = .always
            textField.placeholder = placeholder
            
            // 确保边框颜色正常
            textField.layer.borderColor = nil
            textField.layer.borderWidth = 0
        case .otpCountdown(let placeholder, let seconds):
            textField.rightView = createCountdownRightView(seconds: seconds)
            textField.rightViewMode = .always
            textField.placeholder = placeholder
            
            // 确保边框颜色正常
            textField.layer.borderColor = nil
            textField.layer.borderWidth = 0
        }
        
        if textField.leftView != nil {
            textField.padding = UIEdgeInsets(top: 0, left: (textField.leftView?.frame.width ?? 0) + 10, bottom: 0, right: 10)
        } else if textField.rightView != nil {
            textField.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: (textField.rightView?.frame.width ?? 0) + 10)
        } else {
            textField.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
    }
    
    func updateState(isTip: Bool = false, tipMessage: String? = nil, hightlightTip: String? = nil)
    {
        if isTip, let message = tipMessage {
            tipLabel.isHidden = false
            if let highlightText = hightlightTip, !highlightText.isEmpty {
                tipLabel.attributedText = message.withHighlight(
                    text: highlightText,
                    defaultColor: AppColorStyle.shared.textGray94,
                    highlightColor: AppColorStyle.shared.brandPrimaryDisabled,
                    defaultFont: AppFontProvider.shared.getFont12Medium(),
                )
            } else {
                tipLabel.attributedText = nil
                tipLabel.text = message
            }
        } else {
            textField.layer.borderColor = nil
            textField.layer.borderWidth = 0
            tipLabel.isHidden = true
            
            if errorLabel.isHidden {
                textField.layer.borderColor = nil
                textField.layer.borderWidth = 0
            }
        }
        
        mainStackView.setNeedsLayout()
        mainStackView.layoutIfNeeded()
    }
    
    func updateErrorState(isError: Bool, errorMessage: String? = nil) {
        if isError {
            errorLabel.isHidden = false
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.borderWidth = 1
            errorLabel.text = errorMessage
        } else {
            errorLabel.isHidden = true
            textField.layer.borderColor = nil
            textField.layer.borderWidth = 0
        }
        // ⭐️ 关键
        mainStackView.setNeedsLayout()
        mainStackView.layoutIfNeeded()
    }
    
    // MARK: - 公共方法：更新倒计时
    func updateCountdown(seconds: String) {
        countdownLabel?.text = seconds
    }
}

extension PhoneInputView: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 1. 获取预期的最终文本
        let currentText = textField.text ?? ""
        let nsString = currentText as NSString
        // 这里得到的 newText 是 String 类型
        let newText = nsString.replacingCharacters(in: range, with: string)
        
        // 2. 如果是删除操作 (string 为空)，直接允许并反馈
        if string.isEmpty {
            textFieldAction?(newText, false)
            return true
        }
        
        // 3. 数字校验：只允许输入数字
        guard string.allSatisfy({ $0.isNumber }) else {
            return false
        }
        
        // 4. 长度限制判断
        if let customField = textField as? CustomTextField {
            if newText.count <= customField.maxCount {
                // 在限制范围内
                textFieldAction?(newText, false)
                return true
            } else {
                // 超过限制，第二个参数传 true 表示触发了限制警告
                // 注意这里传递的是 currentText (转换回 String)
                textFieldAction?(currentText, true)
                return false
            }
        }
        
        return true
    }
}

extension PhoneInputView
{
    // MARK: - 辅助方法：创建左右视图
    private func createLeftView(text: String) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        let label = countryCodeLabel
        label.text = text
        let separator = UIView()
        separator.backgroundColor = AppColorStyle.shared.textGrayCE
        
        container.addSubview(label)
        container.addSubview(separator)
        
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.width.greaterThanOrEqualTo(50)
            make.height.greaterThanOrEqualTo(50)
        }
        
        separator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.trailing.equalToSuperview()
            make.leading.equalTo(label.snp.trailing).offset(5)
            make.width.equalTo(1)
            make.height.equalTo(25)
        }
        
        // 约束 container 的宽度
        container.snp.makeConstraints { make in
            make.trailing.equalTo(separator.snp.trailing)
        }
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: 50)
        
        let requiredSize = container.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .required
        )
        container.frame = CGRect(origin: .zero, size: requiredSize)
        return container
    }
    
    private func createRightView(title: String, action: DialogAction?) -> UIView {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(AppColorStyle.shared.brandPrimary, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont12Medium()
        
        self.actionButton = button
        self.buttonAction = action
        button.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        
        let container = UIView()
        container.addSubview(button)
        
        let fieldHeight: CGFloat = 50
        
        container.snp.makeConstraints { make in
            make.height.equalTo(fieldHeight)
            make.width.equalTo(button).offset(10)
        }
        
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: 50)
        let requiredSize = container.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .required
        )
        container.frame = CGRect(origin: .zero, size: requiredSize)
        return container
    }
    
    private func createCountdownRightView(seconds: String) -> UIView {
        let label = UILabel()
        label.text = seconds //"(\(seconds)S)"
        label.font = AppFontProvider.shared.getFont14Semibold()
        label.textColor = AppColorStyle.shared.textGray
        self.countdownLabel = label
        
        let container = UIView()
        container.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.height.greaterThanOrEqualTo(50)
        }

        container.snp.makeConstraints { make in
            make.width.equalTo(label).offset(20)
        }
        
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: 50)
        let requiredSize = container.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .required
        )
        container.frame = CGRect(origin: .zero, size: requiredSize)
        return container
    }
    
}


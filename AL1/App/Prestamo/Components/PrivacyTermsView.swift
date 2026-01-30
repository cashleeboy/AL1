//
//  PrivacyTermsView.swift
//  AL1
//
//  Created by cashlee on 2026/1/22.
//

import UIKit

class PrivacyTermsView: UIView {
    
    var onToggle: ((Bool) -> Void)?
    var onPrivacyTerms: (() -> Void)?
    
    // 1. 将 didSet 逻辑抽离，方便手动调用且逻辑清晰
    private(set) var isAccepted: Bool {
        didSet {
            updateUI()
            onToggle?(isAccepted)
        }
    }
    
    private lazy var privacyTermsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
     
    private let checkBtn: UIButton = {
        let button = UIButton(type: .custom)
        // Fijamos el tamaño del botón para que no se deforme
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 18),
            button.heightAnchor.constraint(equalToConstant: 18)
        ])
        return button
    }()
    
    private lazy var privacyLabel: TapActionLabel = {
        let label = TapActionLabel()
        label.isUserInteractionEnabled = true
        //label.numberOfLines = 0 // Importante para que salte de línea si es largo
        //label.lineBreakMode = .byWordWrapping
        
        let linkText = "Contrato de Préstamo"
        let fullText = "Por favor lea y acepte nuestro Contrato de Préstamo."
        let defaultFont = AppFontProvider.shared.getFont12Regular()
        let linkColor = AppColorStyle.shared.brandPrimary
        let defaultColor = AppColorStyle.shared.textGray
        
        let attributedText = NSMutableAttributedString.makeStyledText(
            fullText: fullText,
            boldParts: [linkText],
            font: defaultFont,
            boldFont: defaultFont,
            textColor: defaultColor,
            boldTextColor: linkColor,
            lineSpacing: nil,
            alignment: .center
        )
        label.setText(attributedText)
        
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        
        return label
    }()
    
    init(isAccepted: Bool) {
        // 2. 先静默设置初始值（不会触发 didSet）
        self.isAccepted = isAccepted
        super.init(frame: .zero)
        setupView()
        // 3. 初始化完成后，手动刷新一次 UI
        updateUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        addSubview(privacyTermsStackView)
        privacyTermsStackView.addArrangedSubview(checkBtn)
        privacyTermsStackView.addArrangedSubview(privacyLabel)
        
        privacyTermsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.leading.equalToSuperview().offset(2)
            make.trailing.equalToSuperview().offset(-2)
            make.bottom.equalToSuperview().offset(-2)
        }
        checkBtn.addTarget(self, action: #selector(didTapCheck), for: .touchUpInside)
        
        // Action del link
        privacyLabel.tap(string: "Contrato de Préstamo") { [weak self] in
            guard let self else { return }
            onPrivacyTerms?()
        }
    }
    
    // 4. 抽取 UI 更新方法
    private func updateUI() {
        let imageName = isAccepted ? "pre_pro_enable" : "pre_pro_disable"
        checkBtn.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @objc private func didTapCheck() {
        isAccepted.toggle()
    }
}

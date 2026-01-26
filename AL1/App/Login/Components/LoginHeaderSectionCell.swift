//
//  LoginHeaderSectionCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//

import UIKit
import SnapKit

enum LoginActionState {
    case normal
    case countdown(countDown: String?)
}

struct LoginHeaderSection: IdentifiableTableItem {
    let identifier: String = UUID().uuidString
    
    var state: LoginActionState
    var isShowLoginButton: Bool
    var areaCode: String?
    var phoneNumber: String?
    var firstResponder: Bool = true
    var inputMaxCount: Int = 9
    // log in
    let iniciarSesionAction: (() -> Void)?
    let fetchAuthAction: (() -> Void)?
    let textFieldOnEdit: ((String) -> Void)?
    let failureAction: ((String) -> Void)?
    let privacyAction: (() -> Void)?
    var privacyToggleAction: ((Bool) -> Void)?
    
    init(state: LoginActionState,
         isShowLoginButton: Bool,
         areaCode: String? = nil,
         phoneNumber: String? = nil,
         firstResponder: Bool = true,
         inputMaxCount: Int = 9,
         iniciarSesionAction: (() -> Void)? = nil,
         fetchAuthAction: (() -> Void)?,
         textFieldOnEdit: ((String) -> Void)?,
         failureAction: ((String) -> Void)?,
         privacyAction: (() -> Void)? = nil,
         privacyToggleAction: ((Bool) -> Void)? = nil,
    ) {
        
        self.state = state
        self.isShowLoginButton = isShowLoginButton
        self.areaCode = areaCode
        self.phoneNumber = phoneNumber
        self.firstResponder = firstResponder
        self.inputMaxCount = inputMaxCount
        self.iniciarSesionAction = iniciarSesionAction
        self.fetchAuthAction = fetchAuthAction
        self.textFieldOnEdit = textFieldOnEdit
        self.failureAction = failureAction
        self.privacyAction = privacyAction
        self.privacyToggleAction = privacyToggleAction
    }
}

class LoginHeaderSectionCell: BaseConfigurablewCell
{
    private let topBackgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "login_BG_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let haloLabel: UILabel = {
        let label = UILabel()
        label.text = "Hola"
        label.font = AppFontProvider.shared.getFont20Bold()
        label.textColor = AppColorStyle.shared.backgroundWhite
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bienvenido a Fácil Crédito"
        label.font = AppFontProvider.shared.getFont14Semibold()
        label.textColor = AppColorStyle.shared.backgroundWhite
        return label
    }()
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "login_gold_icon")
        return imageView
    }()
    
    private let whiteBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        view.setCornerRadius(20, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Inicio de sesión con número de teléfono móvil"
        label.font = AppFontProvider.shared.getFont12Medium()
        label.textColor = AppColorStyle.shared.textBlack50
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(AppColorStyle.shared.backgroundWhite, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont16Bold()
        button.layer.cornerRadius = 8
        button.backgroundColor = AppColorStyle.shared.brandPrimary
        button.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        button.setTitle("Iniciar sesión", for: .normal)
        return button
    }()
    
    private lazy var countdownTimer = CountDownTimer(duration: 60.0)
    private lazy var phoneInputView = PhoneInputView()
    
    private lazy var agreementStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    private lazy var agButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(agressAction(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "pre_login_disable"), for: .normal)
        button.setImage(UIImage(named: "pre_login_enable"), for: .selected)
        button.isSelected = true
        return button
    }()
    
    
    private lazy var privacyLabel: TapActionLabel = {
        let label = TapActionLabel()
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = true
        let fullText = "He aceptado el \"Acuerdo de Privacidad\" y los \"Términos de Servicio\"."
        let boldParts = [
            "\"Acuerdo de Privacidad\"",
            "\"Términos de Servicio\""
        ]
        
        let defaultFont = AppFontProvider.shared.getFont12Regular()
        let linkColor = AppColorStyle.shared.brandPrimary
        let defaultColor = AppColorStyle.shared.textGray
        
        // 单击“下一步”接受隐私协议
        let attributedString = NSMutableAttributedString.makeStyledText(fullText: fullText, boldParts: boldParts, font: defaultFont, textColor: defaultColor, boldTextColor: linkColor, lineSpacing: 6.0)
        
        label.setText(attributedString)
        if let first = boldParts.first {
            label.tap(string: first) { [weak self] in
                guard let self else { return }
                headerSection?.privacyAction?()
            }
        }
        if let last = boldParts.last {
            label.tap(string: last) { [weak self] in
                guard let self else { return }
                headerSection?.privacyAction?()
            }
        }
        return label
    }()
    
    var headerSection: LoginHeaderSection?
    private var buttonHeightConstraint: Constraint?
    private var buttonHeight: CGFloat = 48
    
    override func setupViews() {
        contentView.addSubview(topBackgroundImage)
        
        topBackgroundImage.addSubview(haloLabel)
        topBackgroundImage.addSubview(subtitleLabel)
        topBackgroundImage.addSubview(rightImageView)
        
        contentView.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(titleLabel)
        whiteBackgroundView.addSubview(phoneInputView)
        whiteBackgroundView.addSubview(confirmButton)
        whiteBackgroundView.addSubview(agreementStackView)
        
        agreementStackView.addArrangedSubview(agButton)
        agreementStackView.addArrangedSubview(privacyLabel)

        phoneInputView.textFieldAction = { [weak self] text, _ in
            guard let self else { return }
            headerSection?.textFieldOnEdit?(text)
            
            if case .countdown = headerSection?.state {
                if text.count > 4 {
                    phoneInputView.updateErrorState(isError: true, errorMessage: "Ingrese la OTP correcta")
                } else {
                    phoneInputView.updateErrorState(isError: false)
                }
                confirmButton.isUserInteractionEnabled = !text.isEmpty
                if text.isEmpty {
                    confirmButton.backgroundColor = AppColorStyle.shared.brandPrimaryDisabled
                } else {
                    confirmButton.backgroundColor = AppColorStyle.shared.brandPrimary
                }
            }
        }
        setupLayout()
    }
    
    func setupLayout()
    {
        let headerHeight: CGFloat = 300
        let cardOverlap: CGFloat = 90
        let margin: CGFloat = 20
        
        topBackgroundImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
        
        whiteBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
            make.top.equalTo(topBackgroundImage.snp.bottom).offset(-(cardOverlap))
        }
        
        haloLabel.snp.makeConstraints { make in
            make.top.equalTo(topBackgroundImage.safeAreaLayoutGuide.snp.top).offset(30)
            make.leading.equalToSuperview().offset(margin)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(haloLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(margin)
        }
        rightImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-(margin))
            make.top.equalTo(haloLabel.snp.top).offset(-(margin))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(whiteBackgroundView.snp.top).offset(50)
            make.leading.trailing.equalToSuperview().offset(margin)
        }
        
        phoneInputView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(phoneInputView.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            buttonHeightConstraint = make.height.equalTo(buttonHeight).constraint
        }
         
        agreementStackView.snp.makeConstraints { make in
            make.top.equalTo(confirmButton.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        agButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(20)
        }
        // 关键：防止 agButton 被文字挤压
        agButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        agButton.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    // MARK: - CellConfigurable 协议实现
    override func configure(with item: any TableItemProtocol) {
        guard let item = item as? LoginHeaderSection else { return }
        headerSection = item
        phoneInputView.setMaxCount(item.inputMaxCount)
        
        switch item.state {
        case .normal: 
            phoneInputView.configure(
                style: .phoneNumberInput(countryCode: "+51", placeholder: "Ingresa su tel.", buttonTitle: "Enviar OTP", buttonAction: { [weak self] in
                    guard let self else { return }
                    guard phoneInputView.text?.isEmpty == false else {
                        return
                    }
                    headerSection?.fetchAuthAction?()
                })
            )
            break
        case .countdown(let count):
            if let code = item.areaCode,
               let phoneNumber = item.phoneNumber {

                let tip = "+\(code) \(phoneNumber)"
                phoneInputView.updateState(
                    isTip: true,
                    tipMessage: "El código de verificación ha sido enviado a \(tip)",
                    hightlightTip: tip
                )
            }
            if let count, let interval = TimeInterval(count) {
                if let count = phoneInputView.text?.count, count > 0 {
                    confirmButton.backgroundColor = AppColorStyle.shared.brandPrimary
                } else {
                    confirmButton.backgroundColor = AppColorStyle.shared.brandPrimaryDisabled
                }
                countdownTimer.duration = interval
                phoneInputView.configure(
                    style: .otpCountdown(placeholder: "Por favor escriba OTP", countdownSeconds: "(\(Int(interval))S)"))
                // timer countdown
                countdownTimer.start(update: { [weak self] remainingSeconds in
                    guard let self = self else { return }
                    phoneInputView.updateCountdown(seconds: "(\(remainingSeconds)S)")
                }, completion: { [weak self] in
                    guard let self else { return }
                    phoneInputView.configure(
                        style: .otpInput(placeholder: "Por favor escriba OTP", buttonTitle: "Enviar OTP", buttonAction: {
                            // resend auth code
                            self.headerSection?.fetchAuthAction?()
                        })
                    )
                })
            }
        }
        
        buttonHeightConstraint?.deactivate()
        confirmButton.snp.makeConstraints { make in
            if item.isShowLoginButton {
                buttonHeightConstraint = make.height.equalTo(buttonHeight).constraint
            } else {
                buttonHeightConstraint = make.height.equalTo(0).constraint
            }
        }
        
        if item.firstResponder {
            phoneInputView.isBecomeFirstResponder()
        }
    }
    
    @objc func confirmAction() {
        headerSection?.iniciarSesionAction?()
    }
    
    @objc func agressAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        headerSection?.privacyToggleAction?(sender.isSelected)
    }
    
    deinit {
        countdownTimer.stop()
    }
}

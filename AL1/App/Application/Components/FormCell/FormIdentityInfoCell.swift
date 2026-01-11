//
//  FormIdentityInfoCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

// MARK: - 辅助枚举
enum ImageSource {
    case local(UIImage?)
    case remote(String)
    case none
}

class FormIdentityInfoCell: BaseFormCell
{
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Semibold()
        label.textColor = AppColorStyle.shared.textBlack1C
        label.text = "Tomar foto de su documento de identidad"
        label.numberOfLines = 0
        return label
    }()
    
    lazy var identityBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = AppColorStyle.shared.textGrayF7
        return view
    }()
    
    lazy var identityImageOverlay: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 8
        view.alpha = 0
        return view
    }()
    
    lazy var identityImageView: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "apply_identify_holder"), for: .normal)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var identityHolderView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    lazy var identityTipLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont10Medium()
        label.textColor = AppColorStyle.shared.textBlack
        label.text = "Cargue primero el anverso de su tarjeta de identificación."
        return label
    }()
    
    lazy var guildeTipLabel: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = AppFontProvider.shared.getFont12Regular()
        label.setTitle("Cómo fotografiar？", for: .normal)
        label.setTitleColor(AppColorStyle.shared.brandPrimary, for: .normal)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(identityBackgroundView)
        identityBackgroundView.addSubview(identityImageView)
        identityBackgroundView.addSubview(identityImageOverlay)
        identityBackgroundView.addSubview(identityHolderView)
        identityBackgroundView.addSubview(identityTipLabel)
        contentView.addSubview(guildeTipLabel)
        
        setupLayout()
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        
        identityBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(165) // 根据比例调整
        }
        
        identityImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(190) // 占位图宽度
            make.height.equalTo(100) // 占位图高度
        }
        identityImageOverlay.snp.makeConstraints { make in
            make.edges.equalTo(identityImageView)
        }
        
        identityHolderView.snp.makeConstraints { make in
            make.center.equalTo(identityImageView)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        identityTipLabel.snp.makeConstraints { make in
            make.top.equalTo(identityImageView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
        }
        
        guildeTipLabel.snp.makeConstraints { make in
            make.top.equalTo(identityBackgroundView.snp.bottom).offset(10)
            make.right.equalTo(identityBackgroundView.snp.right)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
    
}

extension FormIdentityInfoCell: FormIdentityInfoFormableRow
{
    func updateIdentityStatus(with status: IdentityStauts, for image: UIImage?) {
        switch status {
        case .unfinish:
            titleLabel.text = "Tomar foto de su documento de identidad"
            titleLabel.textAlignment = .left
            identityHolderView.image = UIImage(named: "apply_camera_icon")
            identityImageOverlay.alpha = 0
        case .failure:
            titleLabel.text = "Haga clic para subir la foto frontal de su cédula de identidad"
            titleLabel.textAlignment = .center
            identityHolderView.image = UIImage(named: "apply_identify_error")
            identityImageOverlay.alpha = 1
            
        case .success:
            titleLabel.text = "Tomar foto de su documento de identidad"
            titleLabel.textAlignment = .left
            identityHolderView.image = UIImage(named: "apply_identify_success")
            identityImageOverlay.alpha = 0
            
            if let image {
                identityImageView.setImage(image, for: .normal)
            }
        }
    }
    
    func updateIdentityStatus(with status: IdentityStauts, url: String) {
        switch status {
        case .unfinish:
            titleLabel.text = "Tomar foto de su documento de identidad"
            titleLabel.textAlignment = .left
            identityHolderView.image = UIImage(named: "apply_camera_icon")
            identityImageOverlay.alpha = 0
        case .failure:
            titleLabel.text = "Haga clic para subir la foto frontal de su cédula de identidad"
            titleLabel.textAlignment = .center
            identityHolderView.image = UIImage(named: "apply_identify_error")
            identityImageOverlay.alpha = 1
            
        case .success:
            titleLabel.text = "Tomar foto de su documento de identidad"
            titleLabel.textAlignment = .left
            identityHolderView.image = UIImage(named: "apply_identify_success")
            identityImageOverlay.alpha = 0
            
            identityImageView.loadImage(url, placeholder: UIImage(named: "apply_identify_success"))
        }
    }
    
    /// 统一的身份状态更新方法
    func updateIdentityStatus(with status: IdentityStauts, imageSource: ImageSource? = nil) {
        // 1. 处理通用状态 UI (文字、图标、遮罩)
        switch status {
        case .unfinish:
            titleLabel.text = "Tomar foto de su documento de identidad"
            titleLabel.textAlignment = .left
            identityHolderView.image = UIImage(named: "apply_camera_icon")
            identityImageOverlay.alpha = 0
            
        case .failure:
            titleLabel.text = "Haga clic para subir la foto frontal de su cédula de identidad"
            titleLabel.textAlignment = .center
            identityHolderView.image = UIImage(named: "apply_identify_error")
            identityImageOverlay.alpha = 1
            
        case .success:
            titleLabel.text = "Tomar foto de su documento de identidad"
            titleLabel.textAlignment = .left
            identityHolderView.image = UIImage(named: "apply_identify_success")
            identityImageOverlay.alpha = 0
        }
        
        // 2. 处理成功时的图片加载逻辑
        if let source = imageSource {
            switch source {
            case .local(let image):
                if let image = image {
                    identityImageView.setImage(image, for: .normal)
                }
            case .remote(let url):
                identityImageView.loadImage(url, placeholder: UIImage(named: "apply_identify_holder"))
                
            default: break
            }
        }
    }
    
    func getHowToPicButton() -> UIButton? { guildeTipLabel }
    func titleFormable() -> UILabel? { titleLabel }
    func getIdentityButtonFormable() -> UIButton? { identityImageView }
}

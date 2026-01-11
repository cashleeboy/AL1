//
//  FaceRecognitionStatusSection.swift
//  AL1
//
//  Created by cashlee on 2025/12/23.
//

import UIKit

enum FaceAuthStepType {
    case uploading   // 加载中/上传中
    case success     // 认证成功
    case failure     // 认证失败
    
    var isProgressVisible: Bool {
        return self == .uploading
    }
    var title: String? {
        switch self {
        case .uploading: return "Cargando…"
        case .success:   return "Verificación exitosa"
        case .failure:   return nil // 失败状态通常顶部显示红色的 "Error en el reconocimiento facial"
        }
    }
    
    var detailText: String? {
        switch self {
        case .uploading: return "Se están enviando los datos del préstamo, por favor espere..."
        default:         return nil
        }
    }
    
    var iconName: String {
        switch self {
        case .uploading: return "face_auth_waiting"
        case .success:   return "face_auth_success" 
        case .failure:   return "face_auth_fail"
        }
    }
}

struct FaceAuthStatusItem: IdentifiableTableItem {
    static let reuseIdentifier = "FaceAuthStatusCell"
    let identifier: String = reuseIdentifier
    let step: FaceAuthStepType
    var currentProgess: CGFloat?
    var totalProgess: CGFloat = 1.0
}


extension FaceAuthStatusItem: PrestamoRowConvertible {
    func toRow(action: ((FaceAuthStatusItem) -> Void)?) -> RowRepresentable {
        return ConcreteRow<FaceAuthStatusItem, FaceAuthStatusCell>(item: self, didSelectAction: action)
    }
}

class FaceAuthStatusCell: BaseConfigurablewCell
{
    private lazy var stateTitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont16Bold()
        label.textColor = UIColor(hex: "#1B1B1B")
        label.textAlignment = .center
        return label
    }()
    
    // 状态图标 (中间的大图)
    private lazy var statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // 辅助描述文案 (如: Se están enviando...)
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Regular() // 通常辅助文案用 Regular
        label.textColor = UIColor(hex: "#858585")
        label.textAlignment = .center
        label.numberOfLines = 0 // 允许换行
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20 // 增加间距以匹配图片视觉
        stack.alignment = .center // 改为居中对齐，因为图标和文字都是居中的
        stack.distribution = .fill
        return stack
    }()
    
    // 1. 定义进度条
    private lazy var progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = AppColorStyle.shared.brandPrimary // 匹配图片的橙色
        progress.trackTintColor = AppColorStyle.shared.textGrayD9    // 浅灰色轨道
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.setProgress(0.1, animated: true)
        return progress
    }()
    
    override func setupViews() {
        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(statusImageView)
        contentStackView.addArrangedSubview(progressBar) // 插入进度条
        
        contentStackView.addArrangedSubview(stateTitleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        
        // 确保图片不被压缩
        statusImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        // 确保文字能撑起 Cell 高度
        descriptionLabel.setContentHuggingPriority(.required, for: .vertical)
        
        // 约束调整
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50) // 增加顶部留白
            make.leading.trailing.equalToSuperview().inset(40)
            // 将 bottom 的优先级降低到 999
            make.bottom.equalToSuperview().offset(-20).priority(999)
        }
        
        // 设置进度条的固定高度
        progressBar.snp.makeConstraints { make in
            make.height.equalTo(8)
            make.width.equalToSuperview() // 撑满 StackView
        }
    }
    
    override func configure(with item: any TableItemProtocol) {
        guard let authItem = item as? FaceAuthStatusItem else { return }
        let step = authItem.step
        
        statusImageView.image = UIImage(named: step.iconName)
        stateTitleLabel.text = step.title
        descriptionLabel.text = step.detailText
        
        stateTitleLabel.isHidden = (step.title == nil)
        descriptionLabel.isHidden = (step.detailText == nil)
   
        if step == .uploading {
            progressBar.isHidden = false
            let current = authItem.currentProgess ?? 0
            let total = authItem.totalProgess
            let progress = Float(current / total)
            
            // 使用动画让进度条滑动更平滑
            progressBar.setProgress(progress, animated: true)
        } else {
            progressBar.isHidden = true
        }
    }
}

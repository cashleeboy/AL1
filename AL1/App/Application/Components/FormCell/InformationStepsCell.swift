//
//  InformationStepsCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit
import SnapKit

class InformationStepsCell: BaseFormCell {
    
    lazy var topBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "base_image_bg")
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var imageSlider: ImageStepSlider = {
        let slider = ImageStepSlider(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 50))
        slider.dotSize = CGSizeMake(16, 16)
        slider.trackHeight = 4
        slider.dotActiveImage = UIImage(named: "dot_active_icon")
        slider.dotInactiveImage = UIImage(named: "dot_normal_icon") 
        slider.activeBarColor = AppColorStyle.shared.activeBackground
        slider.inactiveBarColor = AppColorStyle.shared.inactiveBackground
        slider.labelActiveColor = AppColorStyle.shared.activeBackground
        slider.labelInactiveColor = AppColorStyle.shared.inactiveBackground
        slider.backgroundColor = AppColorStyle.shared.backgroundWhite
        slider.layer.cornerRadius = 5
        slider.isUserInteractionEnabled = false
        return slider
    }()
    
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Medium()
        label.textColor = AppColorStyle.shared.backgroundWhite
        label.numberOfLines = 0 // 允许换行
        label.textAlignment = .left
        label.text = "La información que proporcione se utilizará únicamente para la evaluación crediticia y se mantendrá segura."
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        contentView.addSubview(topBackgroundImageView)
        contentView.addSubview(imageSlider)
        contentView.addSubview(descLabel)
        setupLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topBackgroundImageView.setCornerRadius(20, maskedCorners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
    }
    
    private func setupLayout() {
        let topSafeArea = NavigationUtility.totalTopSafeAreaHeight()
        // 1. 进度条布局
        imageSlider.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topSafeArea + 25)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(60)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(imageSlider.snp.bottom).offset(25)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        topBackgroundImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(descLabel.snp.bottom).offset(20)
        }
    }
    
    // MARK: - Logic / Data Update
    /// 假设这个方法由外部 Row 协议调用，用于刷新 UI
    func updateUI(desc: String?, currentStep: Int, allSteps: [String]) {
        
        descLabel.text = desc
        
        // 更新进度条数据
        imageSlider.steps = allSteps
        imageSlider.currentIndex = currentStep
    }
}

extension InformationStepsCell: InformationStepsFormableRow
{
    func updateStep(with type: InfoReviewType) {
        descLabel.text = type.barSubTitle
        imageSlider.currentIndex = type.rawValue
    }
}

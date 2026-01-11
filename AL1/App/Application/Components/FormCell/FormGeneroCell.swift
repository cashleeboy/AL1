//
//  FormGeneroCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

class FormGeneroCell: BaseFormCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Medium()
        label.textColor = UIColor(hex: "#AFAFAF")
        label.text = "Género"
        return label
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 15
        stack.alignment = .fill
        stack.distribution = .fillEqually // 平分左右宽度
        return stack
    }()

    lazy var hombreItemView: GeneroItemView = {
        let view = GeneroItemView() 
        view.itemButton.tag = 1
        view.itemButton.addTarget(self, action: #selector(didSelectGender(_:)), for: .touchUpInside)
        view.itemButton.isSelected = true
        return view
    }()
    
    lazy var mujerItemView: GeneroItemView = {
        let view = GeneroItemView()
        view.itemButton.tag = 2
        view.itemButton.addTarget(self, action: #selector(didSelectGender(_:)), for: .touchUpInside)
        view.itemButton.isSelected = false
        return view
    }()
    // 实现协议要求的闭包
    var onSelectGenero: ((GeneroType) -> Void)?
    
    override func setupViews() {
        super.setupViews()
        contentView.addSubview(titleLabel)
        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(hombreItemView)
        mainStackView.addArrangedSubview(mujerItemView)
        
        hombreItemView.itemButton.setTitle(GeneroType.Hombre.title, for: .normal)
        mujerItemView.itemButton.setTitle(GeneroType.Mujer.title, for: .normal)
        setupLayout()
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview().inset(15)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(48) // 匹配选择框的标准高度
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    @objc private func didSelectGender(_ sender: UIButton) {
        let isMale = (sender.tag == 1)
        hombreItemView.updateSelection(isSelected: isMale)
        mujerItemView.updateSelection(isSelected: !isMale)
        
        let genderType: GeneroType = isMale ? .Hombre : .Mujer
        onSelectGenero?(genderType)
    }
    
    // 外部设置初始状态
    func setSelection(isMale: Bool) {
        hombreItemView.updateSelection(isSelected: isMale)
        mujerItemView.updateSelection(isSelected: !isMale)
    }
    
    override func updateWithRowFormer(_ rowFormer: RowFormer) {
        if let row = rowFormer as? FormGeneroRowFormer<FormGeneroCell>, let currentGener = row.currentGener {
            setSelection(isMale: currentGener == .Hombre)
        }
    }
}

class GeneroItemView: UIView {
    
    lazy var itemButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(AppColorStyle.shared.textBlack33, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont16Medium()
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    // 2. 独立的图标视图，贴在按钮右侧
    lazy var statusIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "pre_login_disable")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        backgroundColor = UIColor(hex: "#F5F4F4")
        layer.cornerRadius = 8
        
        addSubview(itemButton)
        addSubview(statusIconView)
        
        itemButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        }
        
        statusIconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        itemButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 25)
    }
    
    // 提供一个方法供外部切换状态
    func updateSelection(isSelected: Bool) {
        itemButton.isSelected = isSelected
        statusIconView.image = isSelected ? UIImage(named: "pre_login_enable") : UIImage(named: "pre_login_disable")
    }
}

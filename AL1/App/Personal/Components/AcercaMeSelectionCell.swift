//
//  AcercaMeSelectionCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/25.
//

import UIKit

struct AcercaMeSelectionModel: TableItemProtocol {
    var identifier: String = "AcercaMeSelectionCell"
    var appname: String?
    var appversion: String
    // 说明文字
    var descriptions: [String] = [
            "Somos un equipo de servicio especializado en soluciones de producto digital y operaciones, comprometido a ayudar a las empresas a mejorar su eficiencia ejecutiva y sus resultados de negocio mediante una sólida capacidad de gestión de proyectos y sistemas de operaciones meticulosos.",
            "Nuestro trabajo abarca todo el ciclo de vida del proyecto: desde la planificación inicial y la coordinación de recursos, pasando por la gestión del cronograma, hasta la entrega en hitos clave y su posterior optimización, impulsando así la implementación conforme a lo planificado. Garantizamos la ejecución efectiva de cada objetivo mediante una clara delimitación de responsabilidades, un seguimiento transparente del progreso y mecanismos de colaboración interequipos.",
            "En materia de seguridad y cumplimiento normativo de los datos, nos regimos siempre por procesos de gestión estandarizados, adhiriéndonos estrictamente a las leyes y regulaciones locales, así como a los estándares de la industria, para asegurar un desarrollo comercial estable y sostenible."
        ]
}

extension AcercaMeSelectionModel: PrestamoRowConvertible {
    func toRow(action: ((AcercaMeSelectionModel) -> Void)?) -> RowRepresentable {
        return ConcreteRow<AcercaMeSelectionModel, AcercaMeSelectionCell>(item: self, didSelectAction: action)
    }
}

class AcercaMeSelectionCell: BaseConfigurablewCell {
    
    // 主容器，负责居中对齐图标和标题
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    // 专门存放多段描述文字的容器，左对齐
    private lazy var descriptionStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 20 // 段落之间的间距
        return stack
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "acerca_me_icon")
        imageView.backgroundColor = AppColorStyle.shared.textGrayD9
        imageView.layer.cornerRadius = 16 // 稍微大一点的圆角更现代
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let appTitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont18Semibold()
        label.textColor = AppColorStyle.shared.textBlack
        return label
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Regular()
        label.textColor = AppColorStyle.shared.textGrayA3
        return label
    }()
    
    override func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = AppColorStyle.shared.backgroundWhite
        
        contentView.addSubview(mainStackView)
        
        // 添加上半部分居中组件
        mainStackView.addArrangedSubview(iconImageView)
        mainStackView.setCustomSpacing(15, after: iconImageView)
        mainStackView.addArrangedSubview(appTitleLabel)
        mainStackView.addArrangedSubview(versionLabel)
        
        // 添加下半部分描述容器
        mainStackView.setCustomSpacing(30, after: versionLabel)
        mainStackView.addArrangedSubview(descriptionStackView)
        
        // MARK: - SnapKit 布局
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.bottom.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 85, height: 85))
        }
        
        descriptionStackView.snp.makeConstraints { make in
            make.width.equalToSuperview() // 撑满父容器宽度
        }
    }
    
    override func configure(with item: any TableItemProtocol) {
        guard let model = item as? AcercaMeSelectionModel else { return }
        
        appTitleLabel.text = model.appname
        versionLabel.text = "Versión:\(model.appversion)"
        
        // 关键点：动态清除旧的 Label 并添加新的 Label
        descriptionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for text in model.descriptions {
            let label = UILabel()
            label.font = AppFontProvider.shared.getFont14Regular()
            label.textColor = AppColorStyle.shared.textGrayA3
            label.numberOfLines = 0
            label.textAlignment = .left // 文本内容左对齐
            label.text = text
            descriptionStackView.addArrangedSubview(label)
        }
    }
}

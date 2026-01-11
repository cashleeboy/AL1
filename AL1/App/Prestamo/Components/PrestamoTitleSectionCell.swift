//
//  PrestamoTitleSectionCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/30.
//

import UIKit
import SnapKit

struct PrestamoTitleSectionItem: TableItemProtocol {
    let identifier: String = "PrestamoTitleSectionCell"
    var title: String   
}

extension PrestamoTitleSectionItem: PrestamoRowConvertible {
    func toRow(action: ((PrestamoTitleSectionItem) -> Void)?) -> RowRepresentable {
        return ConcreteRow<PrestamoTitleSectionItem, PrestamoTitleSectionCell>(item: self, didSelectAction: action)
    }
}

class PrestamoTitleSectionCell: BaseConfigurablewCell {
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = AppColorStyle.shared.textBlack
        titleLabel.font = AppFontProvider.shared.getFont16Bold()
        return titleLabel
    }()
    
    override func setupViews() {
         
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
        
    override func configure(with item: any TableItemProtocol) {
        guard let pItem = item as? PrestamoTitleSectionItem else { return }
        titleLabel.text = pItem.title
    }
}

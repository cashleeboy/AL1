//
//  PrestamoEmptySectionCell.swift
//  AL1
//
//  Created by cashlee on 2026/1/4.
//

import UIKit

struct PrestamoEmptyModel: IdentifiableTableItem {
    let identifier: String = "FirstLoamItemCell"
    let uuid: String = UUID().uuidString
    let emptyStatus: EmptyStateConfig
    
    var onSelected: ((EmptyStateConfig) -> Void)?
}

extension PrestamoEmptyModel: PrestamoRowConvertible {
    func toRow(action: ((PrestamoEmptyModel) -> Void)?) -> RowRepresentable {
        return ConcreteRow<PrestamoEmptyModel, PrestamoEmptySectionCell>(item: self, didSelectAction: action)
    }
}

class PrestamoEmptySectionCell: BaseConfigurablewCell {
    private var configTapHandler: ((EmptyStateConfig) -> Void)?
    
    private lazy var emptyView: EmptyStateView = {
       let view = EmptyStateView()
        return view
    }()
    
    override func setupViews() {
        
        contentView.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(260).priority(.high)
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20))
            make.center.equalToSuperview()
        }
    }
    
    
    override func configure(with item: any TableItemProtocol) {
        guard let empty = item as? PrestamoEmptyModel else { return }
        
        let configure = empty.emptyStatus.configuration
        
        emptyView.configure(image: configure.image, title: configure.title, subtitle: configure.subtitle, buttonTitle: configure.buttonTitle) { [weak self] in
            guard let self else { return }
            configTapHandler?(empty.emptyStatus)
        }
        
        configTapHandler = { config in
            empty.onSelected?(config)
        }
    }
}


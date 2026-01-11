//
//  PrestamoProductCard.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//

import UIKit
import SnapKit

struct PrestamoProductCardItem: TableItemProtocol {
    let identifier: String = UUID().uuidString
    var topInset: CGFloat = 0
    
    var list: [PrestamoProductOrderItem] = [
        PrestamoProductOrderItem(),
        PrestamoProductOrderItem(),
//        PrestamoProductOrderItem(),
//        PrestamoProductOrderItem()
    ]
}

extension PrestamoProductCardItem: PrestamoRowConvertible {
    func toRow(action: ((PrestamoProductCardItem) -> Void)?) -> RowRepresentable {
        return ConcreteRow<PrestamoProductCardItem, PreProductOrderSectionCell>(item: self, didSelectAction: action)
    }
}

struct PrestamoProductOrderItem: TableItemProtocol {
    let identifier: String = UUID().uuidString
    var title: String = "en revisión"
    var type: String = "Pagar ahora"
    var priceText: String = "Monto pagado"
    var price: String = "$2,0000"
    var countText: String = "Número de pedidos a pagar"
    var count: String = "5"
}

class PreProductOrderSectionCell: BaseConfigurablewCell {
    private var topInsetConstraint: Constraint?
    
    lazy var topBackgroundView: UIView = {
        let view = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "product_index_BG")
        imageView.contentMode = .scaleToFill
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.distribution = .equalSpacing
        return view
    }()
    
    var dataSources: [PrestamoProductOrderItem] = []
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 100) // 适配宽度
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PreProductOrderCollectionViewCell.self, forCellWithReuseIdentifier: "PreProductOrderCollectionViewCell")
        return collectionView
    }()
    
    override func setupViews() {
        super.setupViews()
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        contentView.addSubview(topBackgroundView)
        contentView.addSubview(collectionView)
        contentView.addSubview(stackView)
        
        topBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
//            topInsetConstraint = make.top.equalToSuperview().offset(0).constraint
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(stackView.snp.bottom).offset(5)
        }
        
        // 2. CollectionView 约束
        collectionView.snp.makeConstraints { make in
            topInsetConstraint = make.top.equalToSuperview().offset(0).constraint
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(100)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    override func configure(with item: any TableItemProtocol) {
        guard let pItem = item as? PrestamoProductCardItem else { return }
        
        self.dataSources = pItem.list
        self.collectionView.reloadData()
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let stackData = pItem.list.dropFirst()
        
        stackData.forEach { order in
            let cardView = PreProductOrderView(item: order)
            stackView.addArrangedSubview(cardView)
            
            // 给每个卡片添加简单的点击手势（逻辑扩展）
            cardView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
            cardView.addGestureRecognizer(tap)
        }
        
        topInsetConstraint?.deactivate()
        collectionView.snp.makeConstraints { make in
            topInsetConstraint = make.top.equalToSuperview().offset(pItem.topInset).constraint
        }
    }
    
    @objc private func handleCardTap() {
        // 处理卡片点击逻辑
    }
}

    // MARK: - UICollectionView Delegate & DataSource

extension PreProductOrderSectionCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 通常 Banner 只显示 1 个或者特定数量
        return dataSources.isEmpty ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreProductOrderCollectionViewCell", for: indexPath) as! PreProductOrderCollectionViewCell
        if let firstItem = dataSources.first {
            cell.configure(with: firstItem)
        }
        return cell
    }
}

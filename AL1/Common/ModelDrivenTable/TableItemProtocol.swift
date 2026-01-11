//
//  TableItemProtocol.swift
//  AL1
//
//  Created by cashlee on 2025/12/13.
//

import UIKit

protocol PrestamoRowConvertible: TableItemProtocol {
    func toRow(action: ((Self) -> Void)?) -> RowRepresentable
}

protocol TableItemProtocol: Hashable {
    var identifier: String { get }
}

protocol IdentifiableTableItem: TableItemProtocol {
    var identifier: String { get }
}

// ⭐️ 在协议扩展中统一实现 Hashable 逻辑
extension IdentifiableTableItem {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

protocol CellConfigurable: AnyObject {
    func configure(with item: any TableItemProtocol)
}

// RowRepresentable 必须继承 AnyObject (类协议)
protocol RowRepresentable: AnyObject {
    var item: any TableItemProtocol { get }
    var reuseIdentifier: String { get }
    var cellClass: AnyClass { get }
    var didSelectAction: ((any TableItemProtocol) -> Void)? { get }
    func configure(cell: UITableViewCell)
    func clone(with item: any TableItemProtocol) -> any RowRepresentable
}

final class ConcreteRow<Item: TableItemProtocol, Cell: UITableViewCell>: RowRepresentable where Cell: CellConfigurable {

    let cellClass: AnyClass = Cell.self
    let reuseIdentifier: String = String(describing: Cell.self)
    
    private let specificItem: Item // 存储具体的 Item 类型
    
    var item: any TableItemProtocol { return specificItem }
    var didSelectAction: ((any TableItemProtocol) -> Void)?
    
    // MARK: 2. 构造器
    init(item: Item, didSelectAction: ((Item) -> Void)? = nil) {
        self.specificItem = item
        
        // 闭包类型擦除转换
        if let specificAction = didSelectAction {
            self.didSelectAction = { selectedItem in
                if let specificItem = selectedItem as? Item {
                    specificAction(specificItem)
                }
            }
        } else {
            self.didSelectAction = nil
        }
    }
    
    // MARK: 3. 方法实现
    func configure(cell: UITableViewCell) {
        guard let specificCell = cell as? Cell else {
            fatalError("Cell dequeued with identifier \(reuseIdentifier) is not of expected type \(Cell.self)")
        }
        specificCell.configure(with: specificItem)
    }
    
    func clone(with item: any TableItemProtocol) -> any RowRepresentable {
        guard let newItem = item as? Item else {
            fatalError("Attempted to clone \(type(of: self)) with incompatible item type: \(type(of: item)). Expected \(Item.self)")
        }
        
        return ConcreteRow(item: newItem) { specificItem in
            if let action = self.didSelectAction {
                action(specificItem)
            }
        }
    }
}
